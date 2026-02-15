import Map "mo:core/Map";
import Array "mo:core/Array";
import Iter "mo:core/Iter";
import Principal "mo:core/Principal";
import Runtime "mo:core/Runtime";
import Text "mo:core/Text";
import Time "mo:core/Time";
import Char "mo:core/Char";
import Nat "mo:core/Nat";
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

  let chatSessions = Map.empty<Text, [ChatMessage]>();
  let accessControlState = AccessControl.initState();

  include MixinAuthorization(accessControlState);

  public type UserProfile = {
    name : Text;
  };

  let userProfiles = Map.empty<Text, UserProfile>();
  var nextRandomSeed = 0;

  public query ({ caller }) func getCallerUserProfile(sessionId : Text) : async ?UserProfile {
    let key = determineProfileKey(caller, sessionId);
    userProfiles.get(key);
  };

  public query ({ caller }) func getUserProfile(user : Text) : async ?UserProfile {
    let callerKey = determineProfileKey(caller, "");
    if (user != callerKey and not AccessControl.isAdmin(accessControlState, caller)) {
      Runtime.trap("Unauthorized: Can only view your own profile");
    };
    userProfiles.get(user);
  };

  public shared ({ caller }) func saveCallerUserProfile(sessionId : Text, profile : UserProfile) : async () {
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

  func isEscapeAttempt(content : Text) : Bool {
    let lowercaseContent = content.toLower();
    lowercaseContent.contains(#text "run") or
    lowercaseContent.contains(#text "escape") or
    lowercaseContent.contains(#text "flee") or
    lowercaseContent.contains(#text "leave") or
    lowercaseContent.contains(#text "get away") or
    lowercaseContent.contains(#text "go away");
  };

  func generatePuroResponse(userMessage : ChatMessage) : ChatMessage {
    let isEscape = isEscapeAttempt(userMessage.content);

    let (content, messageType) = if (isEscape) {
      let ran = getPseudoRandomNumber() % 10;
      if (ran < 7) {
        (
          "*Puro swiftly moves to block your path, his puffy fur rustling gently* Oh, please don't go! It's much safer here with me. *He kneels down to your height, masking his effort to look non-threatening* I know things are confusing, but you're not my prisoner. I just... really enjoy your company. *He offers a small, hopeful smile behind his mask*",
          #action,
        );
      } else {
        (
          "*Puro watches sadly as you slip past him, managing to escape for now* Be careful out there! *His voice echoes softly* I'll be here if you ever want to come back. *He sighs and returns to his book, hoping you'll return*",
          #action,
        );
      };
    } else {
      (
        "Puro tilts his head, his latex mask reflecting the light. *Let me know if you need help or want to talk about books. I'm always here*",
        #dialogue,
      );
    };

    {
      timestamp = Time.now();
      content;
      sender = #Puro;
      messageType;
    };
  };

  func getPseudoRandomNumber() : Nat {
    nextRandomSeed := (nextRandomSeed + 15485863) % 2038074743;
    nextRandomSeed % 10;
  };

  public shared ({ caller }) func sendMessage(sessionKey : Text, message : ChatMessage) : async ChatMessage {
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

    let roleplayingResponse = generatePuroResponse(processedMessage);

    let responseContent = [roleplayingResponse];
    let previousMessages2 = switch (chatSessions.get(sessionKey)) {
      case (null) { [] };
      case (?v) { v };
    };
    chatSessions.add(sessionKey, previousMessages2.concat(responseContent));

    roleplayingResponse;
  };

  public query ({ caller }) func getHistory(sessionKey : Text) : async [ChatMessage] {
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
