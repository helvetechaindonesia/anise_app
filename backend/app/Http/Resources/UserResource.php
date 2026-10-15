<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    /**
     * Transform the resource into an array (Proses Plating JSON).
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'full_name' => $this->full_name,
            'username' => $this->username,
            'email' => $this->email,
            'phone' => $this->phone,
            'address' => $this->address,
            'gender' => $this->gender,
            'religion' => $this->religion,
            'role_id' => $this->role_id,
            'role_type' => $this->role_type,
            'is_active' => $this->is_active,
            'role' => $this->whenLoaded('role'),
            'siswa_profile' => $this->whenLoaded('siswaProfile'),
            'guru_profile' => $this->whenLoaded('guruProfile'),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}
