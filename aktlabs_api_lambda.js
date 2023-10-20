console.log('Loading function');

const AWS_REGION = process.env.region;

exports.handler = async (event, context, callback) => {
    console.log("Entered aktlabs api lambda handler: ",event);
    try{
        const response = {
            msg: "SUCCESS",
            region: AWS_REGION,
            event: event,
        }
        callback(null,response);
    }catch(ex){
        console.log("Error: {}",ex);
        callback(ex,null);
    }
};