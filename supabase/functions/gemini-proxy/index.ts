// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

interface ReqPayload {
    prompt: string;
}

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

function jsonResponse(
    status: number,
    body: { success: boolean; data: unknown; error: string | null },
) {
    return new Response(JSON.stringify(body), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status,
    });
}

Deno.serve(async (req) => {
    // Handle CORS preflight requests
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    // Check for POST method
    if (req.method !== 'POST') {
        return jsonResponse(405, { success: false, data: null, error: 'Method not allowed' });
    }

    try {
        const { prompt }: ReqPayload = await req.json()

        // Validate required parameter
        if (!prompt) {
            return jsonResponse(400, { success: false, data: null, error: 'Missing required parameter: prompt' });
        }

        const api_key = Deno.env.get('GEMINI_API_KEY');
        if (!api_key) {
            console.error('Missing GEMINI_API_KEY environment variable');
            return jsonResponse(503, { success: false, data: null, error: 'Service unavailable' });
        }

        // Separate try/catch for fetch call
        let response: Response;
        let responseData: Record<string, unknown>;
        try {
            response = await fetch(
                `https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent`,
                {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'x-goog-api-key': api_key,
                    },
                    body: JSON.stringify({
                        contents: [
                            {
                                parts: [
                                    { text: prompt },
                                ],
                            },
                        ],
                    }),
                }
            )
            responseData = await response.json()
        } catch (fetchError) {
            console.error('Gemini API fetch error:', fetchError);
            return jsonResponse(503, { success: false, data: null, error: 'Service unavailable' });
        }

        // Handle upstream API errors (Gemini returns {error: {code, message, status}})
        if (responseData.error) {
            const errorInfo = responseData.error as { code?: number; message?: string; status?: string };
            console.error('Gemini API error:', errorInfo);
            return jsonResponse(503, { success: false, data: null, error: 'Service unavailable' });
        }

        // Extract text from response
        const candidates = responseData.candidates as Array<{
            content?: { parts?: Array<{ text?: string }> }
        }> | undefined;

        if (candidates?.[0]?.content?.parts?.[0]?.text) {
            return jsonResponse(200, { success: true, data: { text: candidates[0].content.parts[0].text }, error: null });
        } else {
            // No candidates returned - could be content filtering or empty response
            console.error('Gemini API returned no candidates:', responseData);
            return jsonResponse(503, { success: false, data: null, error: 'Service unavailable' });
        }
    } catch (error) {
        console.error('Gemini proxy error:', error);

        // Check if it's a JSON parsing error (which means bad request body)
        if (error instanceof SyntaxError) {
            return jsonResponse(400, { success: false, data: null, error: 'Bad request' });
        }

        return jsonResponse(503, { success: false, data: null, error: 'Service unavailable' });
    }
})
