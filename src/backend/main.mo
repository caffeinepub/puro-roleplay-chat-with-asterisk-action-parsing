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

  let chatSessions = Map.empty<Principal, [ChatMessage]>();
  let accessControlState = AccessControl.initState();

  include MixinAuthorization(accessControlState);

  public type UserProfile = {
    name : Text;
  };

  let userProfiles = Map.empty<Principal, UserProfile>();

  public query ({ caller }) func getCallerUserProfile() : async ?UserProfile {
    if (not (AccessControl.hasPermission(accessControlState, caller, #user))) {
      Runtime.trap("Unauthorized: Only users can view profiles");
    };
    userProfiles.get(caller);
  };

  public query ({ caller }) func getUserProfile(user : Principal) : async ?UserProfile {
    if (caller != user and not AccessControl.isAdmin(accessControlState, caller)) {
      Runtime.trap("Unauthorized: Can only view your own profile");
    };
    userProfiles.get(user);
  };

  public shared ({ caller }) func saveCallerUserProfile(profile : UserProfile) : async () {
    if (not (AccessControl.hasPermission(accessControlState, caller, #user))) {
      Runtime.trap("Unauthorized: Only users can save profiles");
    };
    userProfiles.add(caller, profile);
  };

  func isAction(text : Text) : Bool {
    let chars = text.toArray();
    chars.size() > 0 and chars[chars.size() - 1] == '*';
  };

  public shared ({ caller }) func sendMessage(message : ChatMessage) : async ChatMessage {
    if (not (AccessControl.hasPermission(accessControlState, caller, #user))) {
      Runtime.trap("Unauthorized: Only users can send messages");
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
    let previousMessages = switch (chatSessions.get(caller)) {
      case (null) { [] };
      case (?v) { v };
    };
    chatSessions.add(caller, previousMessages.concat(newContent));

    let puroResponse = generatePuroResponse(processedMessage);

    let responseContent = [puroResponse];
    let previousMessages2 = switch (chatSessions.get(caller)) {
      case (null) { [] };
      case (?v) { v };
    };
    chatSessions.add(caller, previousMessages2.concat(responseContent));

    puroResponse;
  };

  public query ({ caller }) func getHistory() : async [ChatMessage] {
    if (not (AccessControl.hasPermission(accessControlState, caller, #user))) {
      Runtime.trap("Unauthorized: Only users can view history");
    };

    switch (chatSessions.get(caller)) {
      case (null) { Runtime.trap("No session found") };
      case (?messages) { messages };
    };
  };
};
