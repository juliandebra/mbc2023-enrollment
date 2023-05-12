import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Option "mo:base/Option";
import Debug "mo:base/Debug";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import Account "Account";
import BootcampLocalActor "BootcampLocalActor";
// NOTE: only use for local dev,
// when deploying to IC, import from "rww3b-zqaaa-aaaam-abioa-cai"
// import BootcampLocalActor "BootcampLocalActor";


actor class MotoCoin() {

  public type Account = Account.Account;
  let ledger : TrieMap.TrieMap<Account, Nat> = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual , Account.accountsHash);

  let BootcampLocalActor : actor {
    getAllStudentsPrincipal : shared () -> async [Principal];
  // } = actor("bkyz2-fmaaa-aaaaa-qaaaq-cai");
} = actor("rww3b-zqaaa-aaaam-abioa-cai");

  // Returns the name of the token
  public query func name() : async Text {
    "MotoCoin"
  };

  // Returns the symbol of the token
  public query func symbol() : async Text {
    "MOC"
  };

  // Returns the the total number of tokens on all accounts
  public func totalSupply() : async Nat {
    let arr = Iter.toArray(ledger.vals());
    var total : Nat = 0;
    for(i in arr.vals()){
        total += i
    };

    return total;

  };

  // Returns the default transfer fee
  public query func balanceOf(account : Account) : async (Nat) {
    let acc = ledger.get(account);

    switch(acc){
        case(null){
            return 0;
        };
        case(?acc){
            return acc;
        };
    };
  };


  // Transfer tokens to another account
  public shared ({ caller }) func transfer(
    from : Account,
    to : Account,
    amount : Nat,
  ) : async Result.Result<(), Text> {
    
    let accFrom = ledger.get(from);
    let accTo = ledger.get(to);
    
    switch(accFrom){
        case(null){
            return #err("not implemented")
        };
        case(?accFrom){
          
            switch(accTo){
                case(null){
                    return #err("not implemented")
                };
                case(?accTo){
                    if(accFrom > amount){
                        ledger.put(from, accFrom - amount);
                        ledger.put(from, accTo + amount);
                        return #ok;
                    } else {
                        return #err("not implemented")
                    };
                    
                };
            };
        };  
    };
  };

  // Airdrop 100 MotoCoin to any student that is part of the Bootcamp.
  public func airdrop() : async Result.Result<(), Text> {
      try {
        let p  = await BootcampLocalActor.getAllStudentsPrincipal();
        for(e in p.vals()){
          let acc : Account = {
            owner : Principal = e;
            subaccount : ?Account.Subaccount = null;
          };
          ledger.put(acc, 100);
        };
        return #ok;
      }
      catch(err){
        return #err("not implemented");
      }
    };


  public func getPrin() : async [Principal] {
    let p = await BootcampLocalActor.getAllStudentsPrincipal();
    return p;
  }   
};
   // actor {


    //     // Airdrop 1000 MotoCoin to any student that is part of the Bootcamp.
    //     airdrop : shared () -> async Result.Result<(),Text>;
    // }



//     var ledger = TrieMap.TrieMap<Account.Account, Nat>(Account.accountsEqual, Account.accountsHash);
//     var supply : Nat = 0;

//     public func totalSupply() : async Nat{
//         return suply;
//     };
