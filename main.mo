import Text "mo:base/Text";
import Time "mo:base/Time";
import Bool "mo:base/Bool";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Debug "mo:base/Debug";

actor HomeworkDiary {

    public type Time = Time.Time;

    type Result<Ok, Err> = { #ok : Ok; #err : Err };

    public type Homework = {
        title : Text;
        description : Text;
        dueDate : Time;
        completed : Bool;
    };

    var homeworkDiary = Buffer.Buffer<Homework>(1);

    public shared func addHomework(homework : Homework) : async Nat {
        homeworkDiary.add(homework);
        return homeworkDiary.size() - 1;
    };

    public shared query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
        if(id < homeworkDiary.size()){
            var homework : Homework = homeworkDiary.get(id);
            #ok homework;
        } else {
            #err("not implemented")
        };
    };

    public shared func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
        if(id < homeworkDiary.size()){
            homeworkDiary.put(id, homework);
            return #ok;
        } else {
            return #err("not implemented")
        };
    };

    public shared func markAsCompleted(id : Nat) : async Result.Result<(), Text>{
        if(id < homeworkDiary.size()){
            var get = homeworkDiary.get(id);
            get := {
                title : Text= get.title;
                description : Text = get.description;
                dueDate : Time = get.dueDate;
                completed : Bool = true;
            };
            homeworkDiary.put(id, get);
            return #ok;
        } else {
            return #err("not implemented")
        };
    };


    public shared func deleteHomework(id : Nat) : async Result.Result<(), Text> {
        if(id < homeworkDiary.size()){
            let x = homeworkDiary.remove(id);
            return #ok;
        } else {
            return #err("not implemented")
        };
    };

    public shared query func getAllHomework() : async [Homework] {
        return Buffer.toArray(homeworkDiary);
    };

    public shared query func getPendingHomework() : async [Homework] {
        var pending = Buffer.Buffer<Homework>(1);
        for(homework in homeworkDiary.vals()){
            if(not homework.completed){
                pending.add(homework)
            };
        };
        return Buffer.toArray(pending);
    };

    public shared query func searchHomework(searchTerm: Text) : async [Homework] {
        var taskFound = Buffer.Buffer<Homework>(1);
        for(homework in homeworkDiary.vals()){
            if(searchTerm == homework.title or searchTerm == homework.description){
                taskFound.add(homework)
            };
        };
        return Buffer.toArray(taskFound);
    };
};

