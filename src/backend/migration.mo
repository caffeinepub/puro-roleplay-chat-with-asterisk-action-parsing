import Map "mo:core/Map";
import Principal "mo:core/Principal";
import Time "mo:core/Time";
import Array "mo:core/Array";

module {
  type OldChatMessage = {
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

  type OldUserProfile = {
    name : Text;
  };

  type OldActor = {
    chatSessions : Map.Map<Principal, [OldChatMessage]>;
    userProfiles : Map.Map<Principal, OldUserProfile>;
  };

  type NewChatMessage = {
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

  type NewUserProfile = {
    name : Text;
  };

  type NewActor = {
    chatSessions : Map.Map<Text, [NewChatMessage]>;
    userProfiles : Map.Map<Text, NewUserProfile>;
  };

  public func run(old : OldActor) : NewActor {
    // Manually convert principal-based data to text-based keys
    let newChatSessions = Map.empty<Text, [OldChatMessage]>();
    for ((principal, messages) in old.chatSessions.entries()) {
      newChatSessions.add(principal.toText(), messages);
    };

    let newUserProfiles = Map.empty<Text, OldUserProfile>();
    for ((principal, profile) in old.userProfiles.entries()) {
      newUserProfiles.add(principal.toText(), profile);
    };

    { chatSessions = newChatSessions; userProfiles = newUserProfiles };
  };
};
