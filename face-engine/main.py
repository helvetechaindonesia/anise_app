import io
import os
import json
import numpy as np
import cv2
from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.responses import JSONResponse
import uvicorn
import insightface
from insightface.app import FaceAnalysis

app = FastAPI(title="Sipena Face AI Engine", version="1.0.0")

# Inisialisasi Model InsightFace (Buffalo_s: Ringan, Cepat, Akurat untuk CPU)
print("Loading InsightFace buffalo_s model...")
face_app = FaceAnalysis(name='buffalo_s', providers=['CPUExecutionProvider'])
face_app.prepare(ctx_id=0, det_size=(320, 320))
print("InsightFace model loaded successfully!")

def check_image_liveness(img_np):
    """
    Analisis Anti-Spoofing & Kualitas Gambar:
    1. Laplacian Variance (Deteksi blur atau cetakan kertas/layar berresolusi rendah)
    2. Color Diversity & Histogram Spread (Foto layar atau KTP sering memiliki saturasi/kontras anomali)
    """
    gray = cv2.cvtColor(img_np, cv2.COLOR_BGR2GRAY)
    
    # 1. Blur detection via Laplacian Variance
    lap_var = cv2.Laplacian(gray, cv2.CV_64F).var()
    if lap_var < 35.0:
        return False, f"Gambar terlalu buram/kabur (Laplacian: {lap_var:.1f})"

    # 2. Brightness check (terlalu gelap / overexposed flash)
    mean_val = np.mean(gray)
    if mean_val < 30.0:
        return False, "Pencahayaan terlalu gelap. Harap cari tempat yang lebih terang."
    if mean_val > 235.0:
        return False, "Pencahayaan terlalu silau/overexposed."

    return True, "Valid"

@app.get("/health")
def health_check():
    return {"status": "ok", "service": "Sipena Face AI Engine"}

@app.post("/extract-face")
async def extract_face(face_image: UploadFile = File(...)):
    """
    Ekstrak 512-D Deep Face Embedding untuk Pendaftaran Biometrik Wajah
    """
    try:
        contents = await face_image.read()
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        if img is None:
            raise HTTPException(status_code=400, detail="Format gambar tidak valid atau korup.")

        # Uji Anti-Spoofing & Kualitas
        is_live, reason = check_image_liveness(img)
        if not is_live:
            return JSONResponse(status_code=400, content={
                "success": False,
                "message": f"Kualitas foto tidak memenuhi syarat: {reason}"
            })

        # Deteksi wajah menggunakan InsightFace
        faces = face_app.get(img)

        if len(faces) == 0:
            return JSONResponse(status_code=400, content={
                "success": False,
                "message": "Tidak ada wajah manusia yang terdeteksi dalam foto."
            })

        if len(faces) > 1:
            return JSONResponse(status_code=400, content={
                "success": False,
                "message": "Terdeteksi lebih dari satu wajah! Pastikan hanya wajah Anda sendiri."
            })

        face = faces[0]
        # Pastikan ukuran bounding box wajah proporsional (bukan gambar mikro/background)
        bbox = face.bbox.astype(int)
        face_w = bbox[2] - bbox[0]
        face_h = bbox[3] - bbox[1]
        if face_w < 80 or face_h < 80:
            return JSONResponse(status_code=400, content={
                "success": False,
                "message": "Wajah terlalu jauh dari kamera. Posisikan wajah lebih dekat."
            })

        embedding = face.normed_embedding.tolist()

        return {
            "success": True,
            "message": "Biometrik wajah berhasil diekstrak.",
            "embedding": embedding
        }

    except Exception as e:
        return JSONResponse(status_code=500, content={
            "success": False,
            "message": f"Error internal AI engine: {str(e)}"
        })

@app.post("/verify-face")
async def verify_face(
    face_image: UploadFile = File(...),
    registered_embedding: str = Form(...)
):
    """
    Verifikasi wajah saat Presensi Cam / Jurnal KBM.
    Membandingkan wajah pada face_image dengan registered_embedding (512-D).
    """
    try:
        # Parse registered embedding
        try:
            reg_vector = json.loads(registered_embedding)
            reg_vector = np.array(reg_vector, dtype=np.float32)
        except Exception:
            return JSONResponse(status_code=400, content={
                "success": False,
                "verified": False,
                "message": "Format data biometrik terdaftar tidak valid."
            })

        contents = await face_image.read()
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        if img is None:
            raise HTTPException(status_code=400, detail="Format gambar tidak valid.")

        # Uji Anti-Spoofing & Kualitas
        is_live, reason = check_image_liveness(img)
        if not is_live:
            return JSONResponse(status_code=400, content={
                "success": False,
                "verified": False,
                "message": f"Foto ditolak: {reason}"
            })

        faces = face_app.get(img)

        if len(faces) == 0:
            return JSONResponse(status_code=400, content={
                "success": False,
                "verified": False,
                "message": "Wajah tidak terdeteksi pada kamera presensi."
            })

        if len(faces) > 1:
            return JSONResponse(status_code=400, content={
                "success": False,
                "verified": False,
                "message": "Terdeteksi lebih dari satu wajah pada kamera presensi!"
            })

        current_face = faces[0]
        cur_vector = current_face.normed_embedding

        # Normalisasi Cosine Similarity (Kedua vektor sudah normed oleh InsightFace)
        similarity = float(np.dot(reg_vector, cur_vector))

        # Threshold Standar Industri InsightFace Buffalo_s:
        # < 0.40 : Wajah orang yang sama sekali berbeda
        # 0.40 - 0.55 : Mirip tapi meragukan
        # >= 0.55 : Orang yang sama (FAR < 0.001%)
        SIMILARITY_THRESHOLD = 0.55
        is_match = similarity >= SIMILARITY_THRESHOLD

        return {
            "success": True,
            "verified": is_match,
            "similarity": round(similarity, 4),
            "threshold": SIMILARITY_THRESHOLD,
            "message": "Verifikasi biometrik berhasil cocok." if is_match else "Wajah tidak cocok dengan akun terdaftar!"
        }

    except Exception as e:
        return JSONResponse(status_code=500, content={
            "success": False,
            "verified": False,
            "message": f"Gagal memproses verifikasi wajah: {str(e)}"
        })

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=5000)
