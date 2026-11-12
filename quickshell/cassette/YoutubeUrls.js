.pragma library
function normalize(input) {
    const m = String(input).trim().replace(/^\+\s*(?=https?:)/, '').match(/^https?:\/\/(?:www\.|m\.|music\.)?(youtube\.com|youtu\.be)\/([^\s#]*)(?:#[^\s]*)?$/i);
    if (!m) return "";
    const parts = m[2].split('?');
    const query = (parts[1] || '').split('&');
    let id = '';
    if (m[1].toLowerCase() === 'youtu.be') id = parts[0].split('/')[0];
    else if (parts[0] === 'watch') { const v = query.find(p => p.startsWith('v=')); if (v) id = v.slice(2); }
    else { const p = parts[0].match(/^(?:shorts|live|embed)\/([A-Za-z0-9_-]{11})\/?$/); if (p) id = p[1]; }
    if (!/^[A-Za-z0-9_-]{11}$/.test(id)) id = '';
    const list = query.find(p => p.startsWith('list='));
    if (list && /^[A-Za-z0-9_-]{2,200}$/.test(list.slice(5))) {
        const listId = list.slice(5);
        // YouTube Mixes need a seed video, unlike ordinary playlist URLs.
        if (listId.startsWith('RD')) {
            const seed = id || (/^RD[A-Za-z0-9_-]{11}$/.test(listId) ? listId.slice(2) : '');
            return seed ? 'https://www.youtube.com/watch?v=' + seed + '&list=' + listId : 'https://www.youtube.com/playlist?list=' + listId;
        }
        return 'https://www.youtube.com/playlist?list=' + listId;
    }
    return id ? 'https://www.youtube.com/watch?v=' + id : '';
}
function isPlaylist(url) { return /[?&]list=[A-Za-z0-9_-]+(?:&|$)/.test(String(url)); }
function isMix(url) { return /[?&]list=RD[A-Za-z0-9_-]*(?:&|$)/.test(String(url)); }
function videoId(url) { const m = String(url).match(/[?&]v=([A-Za-z0-9_-]{11})(?:&|$)/); return m ? m[1] : ''; }
