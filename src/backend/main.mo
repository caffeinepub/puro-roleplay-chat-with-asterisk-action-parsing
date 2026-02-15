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

  func neutralResponse(text : Text, messageType : { #action : () ; #dialogue : () }) : Text {
    switch (messageType) {
      case (#action) {
        "Thank you for the message. You mentioned an action: " # text # ". I'm here to respond to your input and have a conversation with you.";
      };
      case (#dialogue) { text };
    };
  };

  func generateNeutralResponse(userMessage : ChatMessage) : ChatMessage {
    {
      timestamp = Time.now();
      content = neutralResponse(userMessage.content, userMessage.messageType);
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
    // No authorization check needed - both authenticated users and guests can view their own profile
    let key = determineProfileKey(caller, sessionId);
    userProfiles.get(key);
  };

  public query ({ caller }) func getUserProfile(user : Text) : async ?UserProfile {
    // Authorization: Users can only view their own profile, admins can view any profile
    let callerKey = determineProfileKey(caller, "");
    
    // For anonymous users, they can only view profiles by sessionId (which would be their own)
    // For authenticated users, callerKey is their principal text
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
    // Authorization: Users can only send messages to their own session, admins can send to any session
    let callerKey = determineProfileKey(caller, sessionKey);
    
    if (sessionKey != callerKey and not AccessControl.isAdmin(accessControlState, caller)) {
      Runtime.trap("Unauthorized: Can only send messages to your own session");
    };

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

    let neutralResponse = generateNeutralResponse(processedMessage);

    let responseContent = [neutralResponse];
    let previousMessages2 = switch (chatSessions.get(sessionKey)) {
      case (null) { [] };
      case (?v) { v };
    };
    chatSessions.add(sessionKey, previousMessages2.concat(responseContent));

    neutralResponse;
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
