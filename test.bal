import ballerinax/github;
import ballerina/io;

configurable string github_token = ?;

public function main() returns error? {
    github:Client githubEp = check new (config = {
        auth: {
            token: github_token
        }
    });

    stream<github:Repository, error?> getRepositoriesResponse = check githubEp->getRepositories();

    github:Repository[]? repos =  check from var r in getRepositoriesResponse
                     select r;
    if repos is () {
        return error ("Error");
    }

    github:Repository[] sorted = from var r in repos
                        // The `order by` clause sorts the output items based on the given `order-key` and `order-direction`.
                        // The `order-key` must be an ordered type.
                        // The `order-direction` is `ascending` if not specified explicitly.
                        order by r.stargazerCount descending 
                        limit 5
                        select r;
    
    foreach var r in sorted {
        //io:println(r); 
        io:println(r.name + " "+ r.stargazerCount.toString()); 
    }



}
