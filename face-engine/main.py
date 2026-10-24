import io
import os
import json
import urllib.request
import numpy as np
import cv2
from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.responses import JSONResponse
import uvicorn
import onnxruntime as ort
import insightface
from insightface.app import FaceAnalysis

app = FastAPI(title="Sipena Enterprise Face AI & Anti-Spoofing Engine", version="2.0.0")

# 1. Inisialisasi Model InsightFace (Buffalo_s: ArcFace 512-D)
print("Loading InsightFace buffalo_s model...")
face_app = FaceAnalysis(name='buffalo_s', providers=['CPUExecutionProvider'])
face_app.prepare(ctx_id=0, det_size=(320, 320))
print("InsightFace model loaded successfully!")

# 2. Inisialisasi Deep Neural Network Anti-Spoofing (Silent-Face MiniFASNetV2)
ANTI_SPOOF_MODEL_PATH = os.path.join(os.path.dirname(__file__), "2.7_80x80_MiniFASNetV2.onnx")
anti_spoof_session = None

def ensure_anti_spoof_model():
    global anti_spoof_session
    if anti_spoof_session is not None:
        return
    
    if not os.path.exists(ANTI_SPOOF_MODEL_PATH):
        print("Downloading MiniFASNetV2 Deep Anti-Spoofing ONNX model...")
        url = "https://github.com/serengil/deepface_models/releases/download/v1.0/2.7_80x80_MiniFASNetV2.onnx"
        urllib.request.urlretrieve(url, ANTI_SPOOF_MODEL_PATH)
        print("MiniFASNetV2 downloaded successfully!")
    
    print("Loading MiniFASNetV2 ONNX session...")
    anti_spoof_session = ort.InferenceSession(ANTI_SPOOF_MODEL_PATH, providers=['CPUExecutionProvider'])
    print("MiniFASNetV2 Anti-Spoofing AI Engine ready!")

try:
    ensure_anti_spoof_model()
except Exception as e:
    print(f"Warning: Failed to auto-load MiniFASNet model on startup: {e}")

def check_deep_liveness(img_np, bbox):
    """
    Evaluasi Anti-Spoofing Multi-Lapisan:
    1. Laplacian Blur & Anomali Kertas/Layar
    2. Deep Neural Network MiniFASNetV2 (Deteksi Tekstur Kulit 3D vs Print Kertas vs Layar HP)
    """
    gray = cv2.cvtColor(img_np, cv2.COLOR_BGR2GRAY)
    
    # Layer 1: Blur detection via Laplacian Variance
    lap_var = cv2.Laplacian(gray, cv2.CV_64F).var()
    if lap_var < 35.0:
        return False, f"Gambar terlalu buram/kabur (Score: {lap_var:.1f})"

    # Layer 2: Deep Learning Anti-Spoofing (MiniFASNetV2)
    if anti_spoof_session is not None:
        try:
            h, w, _ = img_np.shape
            x1, y1, x2, y2 = bbox
            face_w = x2 - x1
            face_h = y2 - y1

            # Scale bounding box 2.7x sesuai standar MiniFASNet
            scale = 2.7
            cx = x1 + face_w / 2.0
            cy = y1 + face_h / 2.0
            new_w = face_w * scale
            new_h = face_h * scale

            crop_x1 = max(0, int(cx - new_w / 2.0))
            crop_y1 = max(0, int(cy - new_h / 2.0))
            crop_x2 = min(w, int(cx + new_w / 2.0))
            crop_y2 = min(h, int(cy + new_h / 2.0))

            face_crop = img_np[crop_y1:crop_y2, crop_x1:crop_x2]
            if face_crop.shape[0] > 10 and face_crop.shape[1] > 10:
                face_resized = cv2.resize(face_crop, (80, 80))
                face_norm = face_resized.astype(np.float32) / 255.0
                face_nchw = np.transpose(face_norm, (2, 0, 1))
                face_tensor = np.expand_dims(face_nchw, axis=0)

                input_name = anti_spoof_session.get_inputs()[0].name
                outputs = anti_spoof_session.run(None, {input_name: face_tensor})
                logits = outputs[0][0]

                # Softmax
                exp_logits = np.exp(logits - np.max(logits))
                probs = exp_logits / np.sum(exp_logits)
                
                # Class 0: Print Spoof (Foto Kertas/KTP)
                # Class 1: Real Human Face (Manusia Asli)
                # Class 2: Replay Spoof (Layar HP/Monitor)
                real_score = float(probs[1])
                print_score = float(probs[0])
                replay_score = float(probs[2])

                # Jika model mendeteksi foto cetak atau layar HP
                if real_score < 0.50 or np.argmax(probs) != 1:
                    reason = "Foto kertas / KTP terdeteksi" if print_score > replay_score else "Layar perangkat / foto digital terdeteksi"
                    return False, f"Manipulasi foto terdeteksi ({reason}, Real Score: {round(real_score * 100)}%)"

        except Exception as e:
            print(f"Deep Anti-Spoofing exception: {e}")

    return True, "Valid"

@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "service": "Sipena Enterprise Face AI Engine",
        "deep_anti_spoof_loaded": anti_spoof_session is not None
    }

@app.post("/extract-face")
async def extract_face(face_image: UploadFile = File(...)):
    """
    Ekstrak 512-D Deep Face Embedding untuk Pendaftaran Biometrik Wajah
    """
    try:
        ensure_anti_spoof_model()
        contents = await face_image.read()
        nparr = np.frombuffer(contents, np.uint8)
        img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

        if img is None:
            raise HTTPException(status_code=400, detail="Format gambar tidak valid atau korup.")

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
        bbox = face.bbox.astype(int)
        face_w = bbox[2] - bbox[0]
        face_h = bbox[3] - bbox[1]
        if face_w < 80 or face_h < 80:
            return JSONResponse(status_code=400, content={
                "success": False,
                "message": "Wajah terlalu jauh dari kamera. Posisikan wajah lebih dekat."
            })

        # Uji Deep Anti-Spoofing (MiniFASNetV2)
        is_live, reason = check_deep_liveness(img, bbox)
        if not is_live:
            return JSONResponse(status_code=400, content={
                "success": False,
                "message": f"Wajah tidak valid: {reason}. Harap gunakan wajah manusia asli."
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
    Membandingkan wajah pada face_image dengan registered_embedding (512-D) + Anti-Spoofing Deep Learning.
    """
    try:
        ensure_anti_spoof_model()
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
        bbox = current_face.bbox.astype(int)

        # Uji Deep Anti-Spoofing (Tolak Foto KTP/Layar HP meskipun digoyang)
        is_live, reason = check_deep_liveness(img, bbox)
        if not is_live:
            return JSONResponse(status_code=400, content={
                "success": False,
                "verified": False,
                "message": f"Presensi ditolak! {reason}. Gunakan wajah manusia asli."
            })

        cur_vector = current_face.normed_embedding

        # Normalisasi Cosine Similarity (Kedua vektor sudah normed oleh InsightFace)
        similarity = float(np.dot(reg_vector, cur_vector))

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
