const express = require('express');
const cors = require('cors');
// Import necessary classes from hk-mahjong
const { Tile, Meld, Hand, WinningHand, ExplorerOfWinningPermutations, FaanCalculator } = require('hk-mahjong');

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// === EXISTING Endpoint for Pre-defined Melds ===
app.post('/calculate', (req, res) => {
    // ... (keep existing code from previous steps) ...
    console.log("Received request body for /calculate:", JSON.stringify(req.body, null, 2));

    try {
        const { melds: meldsData, config: configData } = req.body;
        if (!Array.isArray(meldsData) || meldsData.length !== 5) {
             return res.status(400).json({ error: 'Invalid input: "melds" must be an array of 5 meld objects.' });
        }
         // Convert the JSON data into hk-mahjong objects
        const melds = meldsData.map(meldInfo => {
             // ... (meld creation logic) ...
             if (!meldInfo || !Array.isArray(meldInfo.tiles) || meldInfo.tiles.length < 2 || meldInfo.tiles.length > 4) {
                 throw new Error(`Invalid meld data received: ${JSON.stringify(meldInfo)}`);
             }
             const tiles = meldInfo.tiles.map(tileInfo => {
                 if (!tileInfo || !tileInfo.suit || !tileInfo.value) {
                      throw new Error(`Invalid tile data received: ${JSON.stringify(tileInfo)}`);
                 }
                 return new Tile({ suit: tileInfo.suit, value: tileInfo.value });
             });
             return new Meld(tiles);
        });
        const winningHand = new WinningHand(melds);
        const config = configData || {};
        const faanResult = FaanCalculator.calculate(winningHand, config);
        console.log("Calculation successful for /calculate:", faanResult);
        res.json(faanResult);
    } catch (error) {
        console.error("Calculation error for /calculate:", error.message);
        res.status(400).json({ error: `Calculation failed: ${error.message}` });
    }
});


// === NEW Endpoint for Raw Tiles ===
app.post('/calculate-from-tiles', (req, res) => {
    console.log("Received request body for /calculate-from-tiles:", JSON.stringify(req.body, null, 2));

    try {
        // Expecting { "tiles": [...], "config": {...} }
        const { tiles: tilesData, config: configData } = req.body;

        if (!Array.isArray(tilesData)) {
             return res.status(400).json({ error: 'Invalid input: "tiles" must be an array of tile objects.' });
        }
        // Basic validation - a winning hand usually has 14 tiles (or more with Kongs)
        // You might add more robust validation if needed.
        if (tilesData.length < 14) {
             return res.status(400).json({ error: `Invalid input: Expected at least 14 tiles, received ${tilesData.length}.` });
        }

        // --- Convert raw tile data to Tile objects ---
        const tiles = tilesData.map(tileInfo => {
             if (!tileInfo || !tileInfo.suit || !tileInfo.value) {
                  throw new Error(`Invalid tile data received: ${JSON.stringify(tileInfo)}`);
             }
             return new Tile({ suit: tileInfo.suit, value: tileInfo.value });
        });

        // --- Create a Hand object ---
        // Assuming all tiles are concealed for now. Add revealed melds if needed later.
        const hand = new Hand({ tiles });
        console.log("Created Hand:", hand.toString());

        // --- Explore Winning Permutations ---
        const explorer = new ExplorerOfWinningPermutations(hand);
        const winningPermutations = explorer.getWinningPermutations(); // Returns an array of WinningHand objects

        console.log(`Found ${winningPermutations.length} winning permutation(s).`);

        if (winningPermutations.length === 0) {
            // If no winning permutations are found
            return res.status(400).json({ error: 'Hand does not form a valid winning combination.' });
        }

        // --- Calculate Faan for all permutations and find the best one ---
        // Mahjong scoring typically uses the highest possible Faan value for a hand.
        let bestResult = { value: -1 }; // Use 'value' as Faan is often called 'value' in the library result
        let bestPermutationDetails = null;

        const config = configData || {}; // Use provided config or default

        for (const permutation of winningPermutations) {
            const currentResult = FaanCalculator.calculate(permutation, config);
            console.log(`Permutation: ${permutation.toString()}, Faan: ${currentResult.value}`);

            if (currentResult.value > bestResult.value) {
                bestResult = currentResult;
                bestPermutationDetails = {
                    faan: currentResult.value, // Use 'faan' for clarity in response
                    patterns: currentResult.details, // Assuming 'details' holds the pattern info
                    handStructure: permutation.toString() // Show the winning structure found
                };
            }
        }

        console.log("Best Calculation Result:", bestPermutationDetails);

        // --- Send the best result back ---
        res.json(bestPermutationDetails);

    } catch (error) {
        console.error("Calculation error for /calculate-from-tiles:", error.message, error.stack); // Log stack trace too
        res.status(400).json({ error: `Calculation failed: ${error.message}` });
    }
});


// === Start the Server ===
app.listen(port, () => {
    console.log(`🀄 Mahjong calculation server listening at http://localhost:${port}`);
    console.log('Endpoints:');
    console.log(`  POST /calculate (expects pre-defined melds)`);
    console.log(`  POST /calculate-from-tiles (expects raw tiles)`);
});