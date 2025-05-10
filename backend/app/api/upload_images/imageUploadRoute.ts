import { NextResponse } from 'next/server';
import { read_file_as_base64 } from "@/app/services/supabase/supabase";

// Maximum file size (5MB)
const MAX_FILE_SIZE = 5 * 1024 * 1024;

// Allowed file types
const ALLOWED_FILE_TYPES = ['image/jpeg', 'image/png', 'application/pdf'];

export async function POST(request: Request): Promise<NextResponse> {
    try {
        // Get the form data from the request
        const formData = await request.formData();
        const file = formData.get('image') as File;

        if (!file) {
            return NextResponse.json(
                { error: 'No file provided' },
                { status: 400 }
            );
        }

        // Validate file type
        if (!ALLOWED_FILE_TYPES.includes(file.type)) {
            return NextResponse.json(
                { error: 'Invalid file type. Only JPEG, PNG and PDF are allowed' },
                { status: 400 }
            );
        }

        // Validate file size
        if (file.size > MAX_FILE_SIZE) {
            return NextResponse.json(
                { error: 'File size too large. Maximum size is 5MB' },
                { status: 400 }
            );
        }

        // Convert file to base64
        const bytes = await file.arrayBuffer();
        const buffer = Buffer.from(bytes);
        const base64 = buffer.toString('base64');

        // Here you would typically upload to Supabase
        // For now, we'll just return a success response
        return NextResponse.json({
            success: true,
            fileName: file.name,
            fileType: file.type,
            fileSize: file.size,
            message: 'File received successfully'
        });

    } catch (error) {
        console.error('Error processing file upload:', error);
        return NextResponse.json(
            { error: 'Error processing file upload' },
            { status: 500 }
        );
    }
}
