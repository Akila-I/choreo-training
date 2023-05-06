import wso2/choreo.sendsms;
import wso2/choreo.sendemail;
import ballerinax/trigger.github;
import ballerina/log;
import ballerina/http;

configurable github:ListenerConfig config = ?;

listener http:Listener httpListener = new (8090);
listener github:Listener webhookListener = new (config, httpListener);

configurable string toEmail = ?;
configurable string toMobileNo = ?;

service github:IssuesService on webhookListener {

    remote function onOpened(github:IssuesEvent payload) returns error? {
        //Not Implemented
    }
    remote function onClosed(github:IssuesEvent payload) returns error? {
        //Not Implemented
    }
    remote function onReopened(github:IssuesEvent payload) returns error? {
        //Not Implemented
    }
    remote function onAssigned(github:IssuesEvent payload) returns error? {
        //Not Implemented
    }
    remote function onUnassigned(github:IssuesEvent payload) returns error? {
        //Not Implemented
    }
    remote function onLabeled(github:IssuesEvent payload) returns error? {
        //Not Implemented
        github:Label? label = payload.label;
        if (label is github:Label && label.name == "bug") {

            sendemail:Client sendemailEp = check new ();
            sendsms:Client sendsmsEp = check new ();

            string subject = "Bug Report" + payload.issue.title;
            string messageBody = "A bug has been reported, please check" + payload.issue.html_url;
            
            string sendEmailResponse = check sendemailEp->sendEmail(subject, messageBody, toEmail);
            string sendSmsResponse = check sendsmsEp->sendSms(messageBody, toMobileNo);
            
            log:printInfo("Email sent with response: " + sendEmailResponse);
            log:printInfo("SMS sent with response: " + sendSmsResponse);

        }
    }
    remote function onUnlabeled(github:IssuesEvent payload) returns error? {
        //Not Implemented
    }
}

service /ignore on httpListener {
}
