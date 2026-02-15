import Map "mo:core/Map";
import Array "mo:core/Array";
import Iter "mo:core/Iter";
import Principal "mo:core/Principal";
import Runtime "mo:core/Runtime";
import Text "mo:core/Text";
import Time "mo:core/Time";
import Char "mo:core/Char";
import MixinAuthorization "authorization/MixinAuthorization";
import AccessControl "authorization/access-control";
import Migration "migration";

(with migration = Migration.run)
actor {
  type ChatMessage = {
    timestamp : Time.Time;
    content : Text;
    sender : {
      #Puro;
      #user;
    };
    messageType : {
      #action;
      #dialogue;
    };
  };

  func puroPersonality(text : Text, messageType : { #action : () ; #dialogue : () }) : Text {
    switch (messageType) {
      case (#action) {
        "Um... Puro sees you " # text # ". hehe " # " If you do actions like" # "running, jumping or waving, that`s because you said so in your" # "message. I`m not very good at jumping myself but I love being playful~";
      };
      case (#dialogue) {
        text # " (tail wags)";
      };
    };
  };

  func generatePuroResponse(userMessage : ChatMessage) : ChatMessage {
    {
      timestamp = Time.now();
      content = puroPersonality(userMessage.content, userMessage.messageType);
      sender = #Puro;
      messageType = #dialogue;
    };
  };

  let chatSessions = Map.empty<Text, [ChatMessage]>();
  let accessControlState = AccessControl.initState();

  include MixinAuthorization(accessControlState);

  public type UserProfile = {
    name : Text;
  };

  let userProfiles = Map.empty<Text, UserProfile>();

  public query ({ caller }) func getCallerUserProfile(sessionId : Text) : async ?UserProfile {
    let key = determineProfileKey(caller, sessionId);
    userProfiles.get(key);
  };

  public query ({ caller }) func getUserProfile(user : Text) : async ?UserProfile {
    // Authorization: Users can only view their own profile, admins can view any profile
    let callerKey = if (caller.isAnonymous()) {
      // Anonymous users cannot view other profiles by user text key
      "";
    } else {
      caller.toText();
    };

    if (user != callerKey and not AccessControl.isAdmin(accessControlState, caller)) {
      Runtime.trap("Unauthorized: Can only view your own profile");
    };

    userProfiles.get(user);
  };

  public shared ({ caller }) func saveCallerUserProfile(
    sessionId : Text,
    profile : UserProfile,
  ) : async () {
    // No authorization check needed - both authenticated users and guests can save their own profiles
    let key = determineProfileKey(caller, sessionId);
    userProfiles.add(key, profile);
  };

  func isAction(text : Text) : Bool {
    let chars = text.toArray();
    chars.size() > 0 and chars[chars.size() - 1] == '*';
  };

  func determineProfileKey(caller : Principal, sessionId : Text) : Text {
    if (caller.isAnonymous()) {
      sessionId;
    } else {
      caller.toText();
    };
  };

  public shared ({ caller }) func sendMessage(
    sessionKey : Text,
    message : ChatMessage,
  ) : async ChatMessage {
    // No authorization check needed - both authenticated users and guests can send messages
    let isActionMsg = isAction(message.content);

    let processedMessage = {
      message with
      timestamp = Time.now();
      messageType = if isActionMsg { #action } else { #dialogue };
      content = (
        if (isActionMsg and message.content.size() > 0) {
          let chars = message.content.toArray();
          Text.fromArray(chars.sliceToArray(0, chars.size() - 1));
        } else {
          message.content;
        }
      );
    };

    let newContent = [processedMessage];
    let previousMessages = switch (chatSessions.get(sessionKey)) {
      case (null) { [] };
      case (?v) { v };
    };
    chatSessions.add(sessionKey, previousMessages.concat(newContent));

    let puroResponse = generatePuroResponse(processedMessage);

    let responseContent = [puroResponse];
    let previousMessages2 = switch (chatSessions.get(sessionKey)) {
      case (null) { [] };
      case (?v) { v };
    };
    chatSessions.add(sessionKey, previousMessages2.concat(responseContent));

    puroResponse;
  };

  public query ({ caller }) func getHistory(sessionKey : Text) : async [ChatMessage] {
    // Authorization: Users can only view their own session history, admins can view any history
    let callerKey = determineProfileKey(caller, sessionKey);

    if (sessionKey != callerKey and not AccessControl.isAdmin(accessControlState, caller)) {
      Runtime.trap("Unauthorized: Can only view your own chat history");
    };

    switch (chatSessions.get(sessionKey)) {
      case (null) { Runtime.trap("No session found") };
      case (?messages) { messages };
    };
  };
};

