import azure.functions as func
import logging

app = func.FunctionApp()

@app.route(route="GetVisitorCount", auth_level=func.AuthLevel.ANONYMOUS)
@app.cosmos_db_input(
    arg_name="inputDoc",
    database_name="azureresume",
    container_name="Counter",
    connection="CosmosDbConnection",
    sql_query="SELECT TOP 1 * FROM c WHERE c.id = '1'"
)
@app.cosmos_db_output(
    arg_name="outputDoc",
    database_name="azureresume",
    container_name="Counter",
    connection="CosmosDbConnection"
)


def GetVisitorCount(req: func.HttpRequest, inputDoc: func.DocumentList, outputDoc: func.Out[func.DocumentList]) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    if not inputDoc:
        # If no document exists, create one starting at 1
        count = 1
        new_doc = {"id": "1", "count": count}
    else:
        # If document exists, get the current count and increment
        doc_json = inputDoc[0]
        count = doc_json.get("count", 0) + 1
        new_doc = {"id": "1", "count": count}

    # Save the updated document back to Cosmos DB
    outputDoc.set(func.DocumentList([func.Document(new_doc)]))

    # Return the count to the website
    return func.HttpResponse(
        f"{count}",
        status_code=200
    )