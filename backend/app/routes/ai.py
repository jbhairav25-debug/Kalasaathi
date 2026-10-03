from fastapi import APIRouter, File, HTTPException, UploadFile

from ..ai_classifier import classify_image

router = APIRouter(prefix="/ai", tags=["AI"])


@router.post(
    "/classify",
    openapi_extra={
        "requestBody": {
            "content": {
                "multipart/form-data": {
                    "schema": {
                        "type": "object",
                        "properties": {
                            "file": {"type": "string", "format": "binary"}
                        },
                        "required": ["file"],
                    }
                }
            }
        }
    },
)
async def classify_uploaded_image(file: UploadFile = File(...)):
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=415, detail="Upload an image file")

    image_bytes = await file.read(10 * 1024 * 1024 + 1)
    if len(image_bytes) > 10 * 1024 * 1024:
        raise HTTPException(status_code=413, detail="Image must be 10 MB or smaller")

    try:
        return classify_image(image_bytes)
    except ValueError as error:
        raise HTTPException(status_code=400, detail=str(error)) from error
    except RuntimeError as error:
        raise HTTPException(status_code=503, detail=str(error)) from error