import Map "mo:core/Map";
import Array "mo:core/Array";
import Iter "mo:core/Iter";
import Principal "mo:core/Principal";
import Runtime "mo:core/Runtime";
import Text "mo:core/Text";
import Char "mo:core/Char";
import Time "mo:core/Time";
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

  // Roleplay Puro response generator
  func generateResponse(userMessage : ChatMessage) : ChatMessage {
    let (content, messageType) = switch (userMessage.messageType) {
      case (#action) {
        (
          "Puro sees you " # userMessage.content # ". Actions like jumping, waving, or running might be part of your imagination!",
          #dialogue,
        );
      };
      case (#dialogue) {
        (userMessage.content, #dialogue);
      };
    };

    {
      timestamp = Time.now();
      content;
      sender = #Puro;
      messageType;
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

    let isActionFlag = isAction(message.content);

    let processedMessage = {
      message with
      timestamp = Time.now();
      messageType = if isActionFlag { #action } else { #dialogue };
      content = (
        if (isActionFlag and message.content.size() > 0) {
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

    let puroResponse = generateResponse(processedMessage);

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
