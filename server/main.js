const getCounts = function(network, callbackName, val1, val2) {
  const callback = callbackName || 'console.log';
  try {
    const settings = {};
    if (network === 'stumbleupon') { // JSON to JSONP - No API with JSONP found
      settings.url = `http://www.stumbleupon.com/services/1.01/badge.getinfo?url=${val1}`;
    } else if (network === 'pinterestPins') { // Scraping - No official API
      settings.url = `http://www.pinterest.com/${val1}`;
      settings.regexp = /pinterestapp:pins.*?([\d]+)/;
    } else if (network === 'pinterestFollower') { // Scraping - No official API
      settings.url = `http://www.pinterest.com/${val1}`;
      settings.regexp = /pinterestapp:followers.*?([\d]+)/;
    } else if (network === 'instagram') {
      settings.url = `http://instagram.com/${val1}`;
      settings.regexp = /followed_by.*?([\d]+)/;
    } else if (network === 'googleplus') { // Scraping - No API without API-Key
      settings.url = `https://plusone.google.com/_/+1/fastbutton?url=${val1}`;
      settings.regexp = /window\.__SSR = {c: ([\d]+)/;
    } else if (network === 'buffer') { // Scraping - No API without API-Key
      settings.url = `http://widgets.bufferapp.com/button/?id=0d98d3d464f640bd&url=${val1}&count=vertical&placement=button`;
      settings.regexp = /id="buffer_count">([\d]+)/;
    } else if (network === 'flattr') { // Scraping - No Client JSONP API found
      settings.url = `http://api.flattr.com/button/view/?url=${val1}`;
      settings.regexp = /flattr-count"><span>([\d]+)/;
    } else if (network === 'pocket') { // Scraping - No API without Key found
      settings.url = `https://widgets.getpocket.com/v1/button?label=pocket&count=vertical&url=${val1}`;
      settings.regexp = /id="cnt">([\d]+)/;
    } else if (network === 'codepenProfile') { // Scraping - No API found
      settings.url = `http://codepen.io/${val1}`;
      settings.regexp = new RegExp `href=\"/${val1}/followers\">\\n? *?<strong>([\\d]+)`;
    } else if (network === 'codepenPen') { // Scraping - No API found
      settings.url = `http://codepen.io/${val1}/details/${val2}`;
      settings.regexp = /<strong>([\d]+)<\/strong>\n *?Heart/;
    } else if (network === 'xing') { // Scraping - No Client JSONP API found - counts with letters (eg. 2k) wont work
      settings.url = `https://www.xing-share.com/app/share?op=get_share_button;url=${val1};counter=top;lang=en;type=iframe;hovercard_position=2;shape=rectangle`;
      settings.regexp = /xing-count top">([\d]+)/;
    } else if (network === 'hackernews') { // JSON to JSONP - No (working, keyless) API with JSONP found
      settings.url = `https://news.ycombinator.com/item?id=${val1}`;
      settings.regexp = new RegExp `id=score_${val1}>([\\d]+)`;
    } else if (network === 'surfingbird') {
      settings.url = `http://surfingbird.ru/fix/parsing/${val1}`;
      settings.regexp = /likers-count">([\d]+)/;
    }
    const response = HTTP.get(settings.url);
    if (settings.regexp) {
      return `${callback}(${JSON.stringify(settings.regexp.exec(response.content)[1])});`;
    } else {
      return `${callback}(${response.content});`;
    }
  } catch(error) {
    return `${callback}(0);`;
  }
};

const getRoutes = Picker.filter((req, res) => (req.method === 'GET'));

getRoutes.route('/counts/:network/:val1', (params, req, res, next) => {
  return res.end(getCounts(params.network, params.query.callback, params.val1));
});
getRoutes.route('/counts/:network/:val1/:val2', (params, req, res, next) => {
  return res.end(getCounts(params.network, params.query.callback, params.val1, params.val2));
});
