/**
 * ApisIntel BI Apps Script webhook receiver.
 *
 * Responsibilities:
 * 1) Validate custom X-Api-Key header.
 * 2) Parse incoming inspection JSON payload.
 * 3) Extract Google Drive file ID from webViewLink and build IMAGE() thumbnail formula.
 * 4) Append record to Inspection_Analytics sheet.
 * 5) Force row height = 100 for thumbnail visibility.
 */

const SHEET_NAME = 'Inspection_Analytics';
const EXPECTED_API_KEY = PropertiesService.getScriptProperties().getProperty('ENV_SECRET');

/**
 * Handles POST from Flutter SyncService.
 * @param {GoogleAppsScript.Events.DoPost} e
 * @returns {GoogleAppsScript.Content.TextOutput}
 */
function doPost(e) {
  try {
    const apiKey = getHeaderValue_(e, 'x-api-key');
    if (!apiKey || apiKey !== EXPECTED_API_KEY) {
      return jsonResponse_({ ok: false, error: 'Unauthorized' }, 401);
    }

    if (!e || !e.postData || !e.postData.contents) {
      return jsonResponse_({ ok: false, error: 'Missing request body' }, 400);
    }

    const data = JSON.parse(e.postData.contents);
    const webViewLink = data.photoWebViewLink || '';
    const fileId = extractDriveFileId_(webViewLink);
    const thumbnailFormula = fileId
      ? `=IMAGE("https://drive.google.com/thumbnail?sz=w200&id=${fileId}")`
      : '';

    const sheet = getOrCreateSheet_(SHEET_NAME);

    if (sheet.getLastRow() === 0) {
      sheet.appendRow([
        'Date',
        'Location',
        'HiveID',
        'Thumbnail',
        'PhotoLink',
        'HeaveTest',
        'Activity',
        'Temperament',
        'Mites',
        'Strength',
        'PrimaryToDo',
        'HoneySurplus',
        'SupplementalFeed',
        'FeedProduct',
        'FeedVolumeLiters',
        'FOB',
        'AI Summary',
        'Synced',
        'Payload JSON'
      ]);
      sheet.setFrozenRows(1);
    }

    sheet.appendRow([
      data.createdAt || new Date().toISOString(),
      data.location || '',
      data.hiveId || '',
      thumbnailFormula,
      webViewLink,
      data.heaveTest || 0,
      data.activity || 0,
      data.temperament || '',
      data.miteCount || 0,
      data.finalStrength || '',
      data.primaryTodo || '',
      data.honeySurplus || 0,
      !!data.supplementalFeed,
      data.feedProduct || '',
      data.feedVolumeLiters || 0,
      data.framesOfBees || 0,
      data.aiSummary || '',
      true,
      JSON.stringify(data)
    ]);

    const lastRow = sheet.getLastRow();
    sheet.setRowHeight(lastRow, 100);

    return jsonResponse_({ ok: true, row: lastRow }, 200);
  } catch (error) {
    return jsonResponse_({ ok: false, error: String(error) }, 500);
  }
}

/** Helper: safely read headers from Apps Script event. */
function getHeaderValue_(e, key) {
  if (!e || !e.headers) return null;
  const headers = e.headers;
  const normalized = key.toLowerCase();

  for (const k in headers) {
    if (k && k.toLowerCase() === normalized) {
      return headers[k];
    }
  }
  return null;
}

/** Helper: extract Drive file id from query (?id=) or /d/{id}/ URL. */
function extractDriveFileId_(webViewLink) {
  if (!webViewLink) return '';

  const idQueryMatch = webViewLink.match(/[?&]id=([a-zA-Z0-9_-]+)/);
  if (idQueryMatch && idQueryMatch[1]) {
    return idQueryMatch[1];
  }

  const pathMatch = webViewLink.match(/\/d\/([a-zA-Z0-9_-]+)/);
  return pathMatch && pathMatch[1] ? pathMatch[1] : '';
}

function getOrCreateSheet_(name) {
  const ss = SpreadsheetApp.getActiveSpreadsheet();
  const existing = ss.getSheetByName(name);
  return existing || ss.insertSheet(name);
}

function jsonResponse_(obj, status) {
  return ContentService
    .createTextOutput(JSON.stringify({ status, ...obj }))
    .setMimeType(ContentService.MimeType.JSON);
}
