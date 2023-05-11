import Nat "mo:base/Nat";
import HashMap "mo:base/HashMap";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Int "mo:base/Int";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Array "mo:base/Array";
import Order "mo:base/Order";

actor StudentWall {

    public type Content = {
        #Text: Text;
        #Image: Blob;
        #Video: Blob;
    };

    public type Message = {
        vote: Int;
        content: Content;
        creator: Principal;
    };

    var messageId : Nat = 0;

    let wall = HashMap.HashMap<Nat, Message>(1, Nat.equal, func (x) {Text.hash(Nat.toText(x))});
 
    public shared ({ caller }) func writeMessage(c : Content) : async Nat {
        let id : Nat = messageId;
        messageId+=1;
        let message = {
            vote = 0;
            content = c;
            creator = caller;
        };
        wall.put(messageId, message);
        messageId;
    };

    public shared query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
        switch(wall.get(messageId)) {
            case(null){
                #err("not implemented");
            };
            case(?message){
                #ok message;
            };
        };
    };

    // Update the content for a specific message by ID
    public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {

        let message : ?Message = wall.get(messageId);
        
        switch(message){
            case(null){
                #err("not implemented");
            };
            case(?currentMessage){
                if(Principal.equal(currentMessage.creator, caller)){
                    let updatedMessage : Message = {
                    vote = currentMessage.vote;
                    content = c;
                    creator = currentMessage.creator;
                };
                wall.put(messageId, updatedMessage);
                #ok; 
                } else {
                    #err("not implemented");
                };
                
            };
        };
    };

    // Delete a specific message by ID
    public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
        let message : ?Message = wall.get(messageId);

        switch(message) {
            case(null){
                #err("not implemented");
            };
            case(_){
                ignore wall.remove(messageId);
                #ok;
            };
        };
    };

    // Voting
    public func upVote(messageId : Nat) : async Result.Result<(), Text> {
        let message : ?Message = wall.get(messageId);

        switch(message){
            case(null){
                #err("not implemented");
            };
            case(?currentMessage){
                let upVoteMessage = {
                    vote = currentMessage.vote + 1;
                    content = currentMessage.content;
                    creator = currentMessage.creator;
                };
                wall.put(messageId, upVoteMessage);
                #ok;
            };
        };
    };

    public func downVote(messageId : Nat) : async Result.Result<(), Text> {
        let message : ?Message = wall.get(messageId);

        switch(message){
            case(null){
                #err("not implemented");
            };
            case(?currentMessage){
                let downVoteMessage = {
                    vote = currentMessage.vote - 1;
                    content = currentMessage.content;
                    creator = currentMessage.creator;
                };
                wall.put(messageId, downVoteMessage);

                #ok;
            };
        };
    };

    // Get all messages
    public func getAllMessages() : async [Message] {
        Iter.toArray<Message>(wall.vals());
    };

    private func compare(obj1: Message, obj2 :Message) : Order.Order{
        switch(Int.compare(obj1.vote, obj2.vote)) {
            case (#greater) return #less;
            case (#less) return #greater;
            case(_) return #equal;
        };
    };

    // Get all messages ordered by votes
    public func getAllMessagesRanked() : async [Message] {
        let arr = Iter.toArray<Message>(wall.vals());
        Array.sort(arr, compare);
    };
};


