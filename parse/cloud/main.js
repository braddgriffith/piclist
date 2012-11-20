
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
// 
Parse.Cloud.define("hello", function(request, response) 
{
  response.success("Hello world!");
});


Parse.Cloud.define("sendReceipt", function(request, response) 
{
  	var mailgun = require('mailgun');
	mailgun.initialize('flash.mailgun.org', 'key-6occns3-pai35yanxb89rytl76a10o33');
	
	mailgun.sendEmail({
	  to: "braddgriffith@gmail.com",
	  from: "postmaster@flash.mailgun.org",
	  subject: "Hello from Cloud Code!",
	  text: "Using Parse and Mailgun is great!"
	}, {
	  success: function(httpResponse) {
	    console.log(httpResponse);
	    response.success("Email sent!");
	  },
	  error: function(httpResponse) {
	    console.error(httpResponse);
	    response.error("Uh oh, something went wrong");
	  }
	});
});
