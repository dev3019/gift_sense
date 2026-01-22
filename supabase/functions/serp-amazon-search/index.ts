// Setup type definitions for built-in Supabase Runtime APIs
import "jsr:@supabase/functions-js/edge-runtime.d.ts";

interface ReqPayload {
    query: string;
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
        const { query }: ReqPayload = await req.json()

        // Validate required parameter
        if (!query) {
            return jsonResponse(400, { success: false, data: null, error: 'Missing required parameter: query' });
        }

        const api_key = Deno.env.get('SERP_API_KEY')

        // Construct SerpApi URL with your hidden API key
        const params = new URLSearchParams({
            'k': query,
            'engine': 'amazon',
            'device': 'mobile',
            'amazon_domain': 'amazon.ca',
            'api_key': api_key!, // Keep this on the server!
        })

        // Separate try/catch for fetch call
        let response: Response;
        let responseData: Record<string, unknown>;
        try {
            response = await fetch(`https://serpapi.com/search.json?${params.toString()}`)
            responseData = await response.json()
        } catch (fetchError) {
            console.error('SerpAPI fetch error:', fetchError);
            return jsonResponse(503, { success: false, data: null, error: 'Service unavailable' });
        }

        // Handle upstream API errors (SerpAPI returns {error: "message"})
        if (responseData.error) {
            console.error('SerpAPI error:', responseData.error);
            return jsonResponse(503, { success: false, data: null, error: 'Service unavailable' });
        }

        // Check search_metadata.status for errors
        const searchMetadata = responseData.search_metadata as { status?: string } | undefined;
        if (searchMetadata?.status === 'Error') {
            console.error('SerpAPI search error:', responseData);
            return jsonResponse(503, { success: false, data: null, error: 'Service unavailable' });
        }

        // Extract results
        const organicResults = responseData.organic_results as Array<unknown> | undefined;

        if (organicResults && organicResults.length > 0) {
            return jsonResponse(200, { success: true, data: { results: organicResults }, error: null });
        } else {
            // No results found - this is a valid response, not an error
            return jsonResponse(200, { success: true, data: { results: [] }, error: null });
        }
    } catch (error) {
        console.error('SerpAPI proxy error:', error);

        // Check if it's a JSON parsing error (which means bad request body)
        if (error instanceof SyntaxError) {
            return jsonResponse(400, { success: false, data: null, error: 'Bad request' });
        }

        return jsonResponse(503, { success: false, data: null, error: 'Service unavailable' });
    }
})
