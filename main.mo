import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Error "mo:base/Error";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Timer "mo:base/Timer";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";

import IC "Ic";
import HTTP "Http";
import Type "Types";
import Iter "mo:base/Iter";

actor class Verifier() {

  // "Calculator with id : e35fa-wyaaa-aaaaj-qa2dq-cai should pass verification through your verifier"

  type StudentProfile = Type.StudentProfile;

  stable var studentEntries:[(Principal, StudentProfile)] = [];
  let studentProfileStore : HashMap.HashMap<Principal, StudentProfile> = HashMap.HashMap<Principal, StudentProfile>(1, Principal.equal, Principal.hash );

  // STEP 1 - BEGIN
  public shared ({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    try {
      studentProfileStore.put(caller, profile);
      #ok;
    }
    catch(err){
      #err("not implemented");
    }
  };

  public shared ({ caller }) func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
    let student : ?StudentProfile = studentProfileStore.get(p);

    switch(student){
      case(null){
        return #err("not implemented");
      };
      case(?stud){
        #ok stud;
      }
    };
  };

  public shared ({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
    if(Principal.isAnonymous(caller)){
      #err("not implemented")
    } else {
      studentProfileStore.put(caller, profile);
      #ok;
    }
  };

  public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {
      if(Principal.isAnonymous(caller)){
      #err("not implemented")
    } else {
      ignore studentProfileStore.remove(caller);
      #ok;
    }
  };  

  system func preupgrade(){
    studentEntries := Iter.toArray(studentProfileStore.entries())
  };

  system func postupgrade(){
    for((caller, profile) in studentEntries.vals()){
      studentProfileStore.put(caller, profile);
    };
    studentEntries := [];
  };
  // STEP 1 - END

  // STEP 2 - BEGIN
  type calculatorInterface = Type.CalculatorInterface;
  public type TestResult = Type.TestResult;
  public type TestError = Type.TestError;

  public func test(canisterId : Principal) : async TestResult {
    // let calculator : Type.CalculatorInterface = actor(Principal.toText(canisterId));
    let calculator = actor(Principal.toText(canisterId)) : actor {
      reset : shared () -> async Int;
      add : shared (x : Nat) -> async Int;
      sub : shared (x : Nat) -> async Int;
    };
    // await calculator.reset();
    try{
      let resetCheck : Int = await calculator.reset();
      if(resetCheck != 0){
        return #err(#UnexpectedValue("Unexpected Value"))
      };
      let addCheck : Int = await calculator.add(1);
      if(addCheck != 1){
        return #err(#UnexpectedValue("Unexpected Value"))
      };
      let subCheck : Int = await calculator.sub(1);
      if(subCheck != 1){
        return #err(#UnexpectedValue("Unexpected Value"))
      };
      return #ok();
    }
    catch(err){
      return #err(#UnexpectedError("Unexpected Error"));
    }
  };

  // STEP - 2 END

  // STEP 3 - BEGIN
  // NOTE: Not possible to develop locally,
  // as actor "aaaa-aa" (aka the IC itself, exposed as an interface) does not exist locally

func parseControllersFromCanisterStatusErrorIfCallerNotController(errorMessage : Text) : [Principal] {
    let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
    let words = Iter.toArray(Text.split(lines[1], #text(" ")));
    var i = 2;
    let controllers = Buffer.Buffer<Principal>(0);
    while (i < words.size()) {
      controllers.add(Principal.fromText(words[i]));
      i += 1;
    };
    Buffer.toArray<Principal>(controllers);
  };

  public func verifyOwnership(canisterId : Principal, p : Principal) : async Bool {
    let mgmtCanister : IC.ManagementCanisterInterface = actor("aaaaa-aa");
    try{
      let result = await mgmtCanister.canister_status({ canister_id = canisterId});
      let controller = result.settings.controllers;
      for(principal in controller.vals()){
        if(principal == p) return true;
      };
      return false;
    }
    catch(err){
      let message = Error.message(err);
      let controllers = parseControllersFromCanisterStatusErrorIfCallerNotController(message);
      for(principal in controllers.vals()){
        if(principal == p){
          return true;
        };
      };
      return false;
    }
  };
  // STEP 3 - END

  // STEP 4 - BEGIN
  public shared ({ caller }) func verifyWork(canisterId : Principal, p : Principal) : async Result.Result<(), Text> {
    let isOwner = await verifyOwnership(canisterId, p);
    if(not isOwner){
      return #err("Verifying owner failed")
    };
    let result = await test(canisterId);
    switch(result){
      case(#err(_)){
        #err("test failed")
      };
      case(#ok){
        switch(studentProfileStore.get(p)){
          case(null){
            return #err("Profile not found");
          };
          case(?profile){
            let graduated = {
              name = profile.name;
              team = profile.team;
              graduate = true
            };
            studentProfileStore.put(p, graduated);
            return #ok();
          };
        };
      };
    };
  };
  // STEP 4 - END

  // STEP 5 - BEGIN
  // public type HttpRequest = HTTP.HttpRequest;
  // public type HttpResponse = HTTP.HttpResponse;

  // // NOTE: Not possible to develop locally,
  // // as Timer is not running on a local replica
  // public func activateGraduation() : async () {
  //   return ();
  // };

  // public func deactivateGraduation() : async () {
  //   return ();
  // };

  // public query func http_request(request : HttpRequest) : async HttpResponse {
  //   return ({
  //     status_code = 200;
  //     headers = [];
  //     body = Text.encodeUtf8("");
  //     streaming_strategy = null;
  //   });
  // };
  // STEP 5 - END
};





  //  public type TestResult = Result.Result<(), TestError>;
  //   public type TestError = {
  //       #UnexpectedValue : Text;
  //       #UnexpectedError : Text;
  //   };




