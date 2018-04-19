package com.skybettingandgaming.demos.paypoc.kotlin

import kotlin.system.exitProcess
import java.util.UUID

import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import com.amazonaws.AmazonServiceException
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder
import com.amazonaws.services.dynamodbv2.document.DynamoDB
import com.amazonaws.services.dynamodbv2.document.Item
import com.amazonaws.services.dynamodbv2.document.PutItemOutcome
import org.springframework.web.util.UriComponentsBuilder
import org.apache.logging.log4j.LogManager

class Handler : RequestHandler<Map<String, Any>, ApiGatewayResponse> {

    companion object {
        private val LOG = LogManager.getLogger(Handler::class.java)
    }

    /**
     * AWS Lambda handler function
     * @param input Map Input fields
     * @param context Context Lambda function context
     * @return ApiGateWayResponse returned to gateway en route to requesting browser
     */
    override fun handleRequest(input: Map<String, Any>, context: Context): ApiGatewayResponse {
        LOG.info("received: " + input.keys.toString())

        // decode using Spring
        val bodystr: String = "http://www.example.com/index.html?" + input.get("body").toString()
        val parameters = UriComponentsBuilder.fromUriString(bodystr).build().getQueryParams()
        var name: String? = parameters.get("name")?.first()
        var number: String? = parameters.get("number")?.first()
        var expirymonth: String? = parameters.get("expirymonth")?.first()
        var expiryyear: String? = parameters.get("expiryyear")?.first()
        var cvv: String? = parameters.get("cvv")?.first()

        // fill with defaults if not submitted
        if (name == null) name = "MRS A. N. OTHER"
        if (number == null) number = makeRandom(0, 9999, "XXXX-XXXX-XXXX-XXXX")
        if (expirymonth == null) expirymonth = makeRandom(1, 12, "XX")
        if (expiryyear == null) expiryyear = makeRandom(19, 26, "XX")
        if (cvv == null) cvv = makeRandom(0, 999, "XXX")

        // write values to database
        writeToDB(name, number, "${expirymonth}/${expiryyear}", cvv)

        // write only log reference back to response
        val log_targets = String.format("Kotlin function executed successfully.  log_group = %s, log_stream = %s", context.getLogGroupName(), context.getLogStreamName())
        return ApiGatewayResponse.build {
            statusCode = 200
            objectBody = MsgResponse(log_targets)
            headers = mapOf("X-Powered-By" to "AWS Lambda")
        }
    }

    /**
     * Write card details to database
     * @param name String
     * @param number String
     * @param expiry String
     * @param cvv String
     */
    fun writeToDB(name: String, number: String, expiry: String, cvv: String): PutItemOutcome {
        val client = AmazonDynamoDBClientBuilder.standard().build()
        val dynamoDB = DynamoDB(client)
        val table_name = "Kards"
        var table = dynamoDB.getTable(table_name)
        var outcome: PutItemOutcome

        // build the item
        val uuid = UUID.randomUUID()
        val item = Item()
                .withPrimaryKey("UserId", uuid.toString())
                .withString("Name", name)
                .withString("Number", number)
                .withString("Expiry", expiry)
                .withString("CVV", cvv)

        try {
            // write the item to the table
            outcome = table.putItem(item)
        } catch (e: AmazonServiceException) {
            LOG.error("Amazon Service Exception: " + e)
            exitProcess(1)
        }
        return outcome
    }

    /**
     * Create random string of digits matching format specifier
     */
    fun makeRandom(min: Int, max: Int, format: String): String {
        var output: String = ""
        val separator: String = "-"
        // split format up into XX blocks
        val chunks: List<String> = format.split(separator)
        // loop through blocks and substitute
        chunks.forEachIndexed { index, chunk ->
            // 2nd, 3rd, nth chunk is preceded by a separator
            if (index > 0) {
                output += separator
            }
            // create a random number and pad to be the correct length
            val rnd: Int = Math.floor((Math.random() * (max - min)) + min).toInt()
            val chnum = String.format("%0" + chunk.length + "d", rnd)
            // append number to output
            output += "" + chnum;
        }
        return output;
    }


}
