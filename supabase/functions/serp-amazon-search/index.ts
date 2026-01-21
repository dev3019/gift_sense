// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";
interface ReqPayload {
    query: string;
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
        const { query }: ReqPayload = await req.json()
        const api_key = Deno.env.get('SERP_API_KEY')

        // Construct SerpApi URL with your hidden API key
        const params = new URLSearchParams({
            'k': query,
            'engine': 'amazon',
            'device': 'mobile',
            'amazon_domain': 'amazon.ca',
            'api_key': api_key, // Keep this on the server!
        })

        const response = await fetch(`https://serpapi.com/search.json?${params.toString()}`)
        const responseData = await response.json()

        let data = {}
        if (responseData['organic_results'] && responseData['organic_results'].length > 0) {
            data = {
                success: true,
                results: responseData['organic_results']
            }
        } else {
            data = {
                success: false,
                results: []
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
