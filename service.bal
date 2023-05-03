import ballerina/http;
import ballerina/log;
import ballerinax/github;

configurable string githubAccessToken = ?;

type SummarizedIssue record {
    int number;
    string title;
};

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function get summary/[string orgName]/repository/[string repoName]() returns SummarizedIssue[]?|error {

        log:printInfo("New request for " + orgName + " " + repoName);

        github:Client githubClient = check new ({auth: {token: githubAccessToken}});

        stream<github:Issue, error?> getIssuesResponse = check githubClient->getIssues(owner = orgName, repositoryName = repoName, issueFilters = {states: [github:ISSUE_OPEN]});

        SummarizedIssue[]? summary = check from github:Issue issue in getIssuesResponse
            order by issue.number descending
            limit 10
            select {number: issue.number, title: issue.title.toString()};
        
        return summary;
    }
};
