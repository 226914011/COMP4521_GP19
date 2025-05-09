/* eslint-disable max-len */
/* eslint-disable require-jsdoc */
// Firebase Functions import
const functions = require("firebase-functions");

// Your existing imports from server.js
const express = require("express");
const cors = require("cors");
const {
  Tile,
  Meld,
  Hand,
  WinningHand,
  ExplorerOfWinningPermutations,
  FaanCalculator,
} = require("hk-mahjong");
// Ensure 'hk-mahjong' is in functions/package.json

// Initialize your Express app (same as in server.js)
const app = express();
app.use(cors({credentials: true, origin: true})); // Allows all origins
app.use(express.json());

// Helper function to format Faan value for JSON response
function formatFaanValue(value) {
  if (value === Infinity) {
    return "LIMIT"; // Or "MAX_FAAN", "∞"
  }
  return value; // Return the number if it's finite
}

// === Endpoint for Pre-defined Melds (copied from server.js) ===
app.post("/calculate", (req, res) => {
  console.log(
      "Function /calculate: Received request body:",
      JSON.stringify(req.body, null, 2),
  );

  try {
    const {melds: meldsData, config: configData} = req.body;
    if (!Array.isArray(meldsData) || meldsData.length !== 5) {
      return res.status(400).json({
        error: "Invalid input: \"melds\" must be an array of 5 meld objects.",
      });
    }
    const melds = meldsData.map((meldInfo) => {
      if (
        !meldInfo ||
        !Array.isArray(meldInfo.tiles) ||
        meldInfo.tiles.length < 2 ||
        meldInfo.tiles.length > 4
      ) {
        throw new Error(
            `Invalid meld data received: ${JSON.stringify(meldInfo)}`,
        );
      }
      const tiles = meldInfo.tiles.map((tileInfo) => {
        if (!tileInfo || !tileInfo.suit || !tileInfo.value) {
          throw new Error(
              `Invalid tile data received: ${JSON.stringify(tileInfo)}`,
          );
        }
        return new Tile({suit: tileInfo.suit, value: tileInfo.value});
      });
      return new Meld(tiles);
    });
    const winningHand = new WinningHand(melds);
    const config = configData || {};
    const faanResult = FaanCalculator.calculate(winningHand, config);
    console.log("Function /calculate: Calculation successful:", faanResult);
    res.json(faanResult);
  } catch (error) {
    console.error(
        "Function /calculate: Calculation error:",
        error.message,
        error.stack,
    );
    res.status(400).json({error: `Calculation failed: ${error.message}`});
  }
});

// === Endpoint for Raw Tiles (copied from server.js) ===
app.post("/calculate-from-tiles", (req, res) => {
  console.log(
      "Function /calculate-from-tiles: Received request body:",
      JSON.stringify(req.body, null, 2),
  );

  try {
    const {tiles: tilesData, config: configData} = req.body;

    if (!Array.isArray(tilesData)) {
      return res.status(400).json({
        error: "Invalid input: \"tiles\" must be an array of tile objects.",
      });
    }
    if (tilesData.length < 14) { // Basic validation
      return res.status(400).json({
        error: `Invalid input: Expected at least 14 tiles, ` +
               `received ${tilesData.length}.`,
      });
    }

    const tiles = tilesData.map((tileInfo) => {
      if (!tileInfo || !tileInfo.suit || !tileInfo.value) {
        throw new Error(
            `Invalid tile data received: ${JSON.stringify(tileInfo)}`,
        );
      }
      return new Tile({suit: tileInfo.suit, value: tileInfo.value});
    });

    const hand = new Hand({tiles});
    console.log(
        "Function /calculate-from-tiles: Created Hand:", hand.toString(),
    );

    const explorer = new ExplorerOfWinningPermutations(hand);
    const winningPermutations = explorer.getWinningPermutations();

    console.log(
        `Function /calculate-from-tiles: Found ` +
      `${winningPermutations.length} winning permutation(s).`,
    );

    if (winningPermutations.length === 0) {
      return res.status(400).json({
        error: "Hand does not form a valid winning combination.",
      });
    }

    // eslint-disable-next-line prefer-const
    let bestResult = {value: -1};
    let bestPermutationDetails = null;
    const config = configData || {};

    for (const permutation of winningPermutations) {
      const currentResult = FaanCalculator.calculate(permutation, config);
      console.log(
          `Function /calculate-from-tiles: Permutation: ` +
        `${permutation.toString()}, Faan: ${currentResult.value}`,
      );

      let numericCurrentFaan;
      if (
        typeof currentResult.value === "string" &&
        currentResult.value === "∞"
      ) {
        numericCurrentFaan = Number.POSITIVE_INFINITY;
      } else if (typeof currentResult.value === "number") {
        // This includes actual Number.POSITIVE_INFINITY
        // if the library ever returns it
        numericCurrentFaan = currentResult.value;
      } else {
        // Fallback for unexpected types, though library docs suggest number
        // or '∞'
        console.warn(
            `Unexpected Faan value type from library: ${typeof currentResult.value}, ` +
          `value: ${currentResult.value} for permutation ${permutation.toString()}`,
        );
        numericCurrentFaan = -Infinity;
        // Treat as lowest possible to not interfere with best score logic,
        // or handle as error
      }

      console.log(
          `Function /calculate-from-tiles: Permutation: ${permutation.toString()}, ` +
      `Raw Faan: ${currentResult.value}, Numeric Faan: ${numericCurrentFaan}`,
      );
      if (numericCurrentFaan > bestResult.value) {
        console.log(
            `Function /calculate-from-tiles: New best Faan. Old best: ${bestResult.value}, ` +
            `New numeric: ${numericCurrentFaan}`,
        );
        bestResult.value = numericCurrentFaan;
        bestPermutationDetails = {
          faan: formatFaanValue(numericCurrentFaan),
          patterns: currentResult.details,
          handStructure: permutation.toString(),
        };
      }
    }

    console.log(
        "Function /calculate-from-tiles: Best Calculation Result:",
        bestPermutationDetails,
    );
    res.json(bestPermutationDetails);
  } catch (error) {
    console.error(
        "Function /calculate-from-tiles: Calculation error:",
        error.message,
        error.stack,
    );
    res.status(400).json({error: `Calculation failed: ${error.message}`});
  }
});

// === Export the Express app as an HTTPS Cloud Function ===
// The name 'api' here will become part of your function's URL.
// For example: https://<region>-<project-id>.cloudfunctions.net/api/calculate
exports.api = functions.https.onRequest(app);
