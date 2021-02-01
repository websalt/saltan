function metalStatus(element) {
    if (element['category'].includes('metalloid')
        || element['category'].includes('nonmetal')) {
        return 'non-metal';
    } else if (element['category'].includes('noble gas')) {
        return 'noble gas';
    } else {
        return 'metal';
    }
}

function getSymbol(node) {
    return node['symbol'].toLowerCase().replace(/[0-9]/,'');
}

function print(content) {
    document.getElementById('main').innerText = content;
}

function prettyPresent(node) {
    let prettified = node['symbol'] + ' ' + node['name'];
    if (node['number']) {
        return prettified + ' '+ node['number'];
    } else {
        return prettified
    }
}


function categorize(data) {
    var categorized = {metals: [], nonmetals: []};

    for (i = 0; i < data['elements'].length; i++)  {
        let element = data['elements'][i];
        let elem_status = metalStatus(element);
        if (elem_status == 'metal') {
            categorized.metals.push(element);
        } else if (elem_status == 'non-metal') {
            categorized.nonmetals.push(element);
        }
    }

    for (i = 0; i < data['polyatomics'].length; i++) {
        let ion = data['polyatomics'][i];
        if (ion['charge'] > 0) {
            categorized.metals.push(ion);
        } else {
            categorized.nonmetals.push(ion);
        }
    }
    return categorized;
}

function sortString(str) {
    return str.split('').sort((a, b) => a.localeCompare(b)).join('');
}

function main(data, phrase) {
    if (!phrase) {
        phrase = (window.location.hash.slice(1) || 'Salt');
    }

    let sorted_phrase = sortString(phrase.toLowerCase())
    let categorized = categorize(data);

    var content = phrase + "\n";
    var has_salt = false;
    for (x = 0; x < categorized.metals.length; x++) {
        let metal = categorized.metals[x];
        for (y = 0; y < categorized.nonmetals.length; y++) {
            let nonmetal = categorized.nonmetals[y];
            let combo = sortString(getSymbol(metal) + getSymbol(nonmetal));
            if (combo == sorted_phrase) {
                if (has_salt) {
                    content += "\n"
                }
                content += prettyPresent(metal) + "\n";
                content += prettyPresent(nonmetal) + "\n";
                has_salt = true;
            }
        }
    }
    if (!has_salt) {
        content += "No salts were found";
    }
    print(content);
}

function keyHandler(k) {
    if (k.key == 'Enter') {
        let input = document.getElementById('phrase');
        main(JSON.parse(localStorage.getItem('data')), input.value);
        input.value = "";
    }
}

async function onLoad() {
    var data = localStorage.getItem('data');
    if (data) {
        data = JSON.parse(data);
    } else {
        data = await fetch('periodic-compressed.json').then(
            function(response) {return response.json()});
        localStorage.setItem('data', JSON.stringify(data));
    }
    document.getElementById('phrase').addEventListener('keypress',
                                                       keyHandler);
    main(data);
}
