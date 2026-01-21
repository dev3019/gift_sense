// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

interface ReqPayload {
    prompt: string;
}

const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req) => {
    // Handle CORS preflight requests
    if (req.method === 'OPTIONS') {
        return new Response('ok', { headers: corsHeaders })
    }

    try {
        const { prompt }: ReqPayload = await req.json()
        const api_key = Deno.env.get('GEMINI_API_KEY')

        const response = await fetch(
            `https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent`,
            {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'x-goog-api-key': api_key!,
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

        const responseData = await response.json()
        let data = {}
        if (responseData['candidates'] && responseData['candidates'].length > 0 && responseData['candidates'][0]['content'] && responseData['candidates'][0]['content']['parts'] && responseData['candidates'][0]['content']['parts'].length > 0) {
            data = {
                success: true,
                text: responseData['candidates'][0]['content']['parts'][0]['text'],
            }
        } else {
            data = {
                success: false,
                text: ''
            }
        }

        return new Response(JSON.stringify(data), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
        })
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 400,
        })
    }
})
