import ballerina/http;
import ballerinax/github;
import ballerina/io;


type GithubRepoData record {
    string reponame;
    int stars = 0;
};

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    # A resource for generating greetings
    # + name - the input string name
    # + return - string name with hello message or error
    resource function get topStarRepos(int repoCount = 5) returns GithubRepoData[]|error {
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
    

        GithubRepoData[] results = [];
        int index = 0;
        foreach var r in sorted {
            //io:println(r); 
            io:println(r.name + " "+ r.stargazerCount.toString()); 
            results[index] = {reponame: r.name, stars: r.stargazerCount?:0}; 
        }
        return results; 
    }
}
