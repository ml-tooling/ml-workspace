#!/usr/local/bin/python3

from fastapi import FastAPI

app = FastAPI(openapi_prefix="./")

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}

if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8091, log_level="info", reload=True)