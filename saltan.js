function metalStatus(element) {
    if (element['category'].includes('metalloid')
        || element['category'].includes('nonmetal')) {
        return false;
    } else if (element['category'].includes('noble gas')) {
        return undefined;
    } else {
        return true;
    }
}

async function fetchData() {
    const elements = fetch(
        'https://api.github.com/repos/Bowserinator/Periodic-Table-JSON/contents/PeriodicTableJSON.json'
    ).then(function(data) {return data.json()}).then(
        function(data) {
            return JSON.parse(atob(data['content']))['elements']});

    const polyatomic_ions = fetch(
        'https://api.github.com/repos/websalt/saltan/contents/polyatomic_ions.json'
    ).then(function(data) {return data.json()}).then(
        function(data) {
            return JSON.parse(atob(data['content']))});

    return {"elements": await elements,
            "polyatomic_ions": await polyatomic_ions};
}

function getSymbol(node) {
    return node['symbol'].toLowerCase().replace(/[^a-z]/g,'');
}

function print(content) {
    document.getElementById('main').innerText = content;
}

function prettyPresent(node) {
    const prettified = node['symbol'] + ' ' + node['name'];
    if (node['number']) {
        return prettified + ' '+ node['number'];
    } else {
        return prettified
    }
}


function categorize(data) {
    var categorized = {metals: {}, nonmetals: {}};

    for (i = 0; i < data['elements'].length; i++)  {
        let element = data['elements'][i];
        let elem_status = metalStatus(element);
        if (elem_status) {
            categorized.metals[element.name] = element;
        } else if (elem_status === false) {
            categorized.nonmetals[element.name] = element;
        }
    }

    for (i = 0; i < data['polyatomic_ions'].length; i++) {
        let ion = data['polyatomic_ions'][i];
        if (ion['charge'] > 0) {
            categorized.metals[ion.name] = ion;
        } else {
            categorized.nonmetals[ion.name] = ion;
        }
    }
    return categorized;
}

function countChars(str) {
    var charcounts = {};
    for (i = 0; i < str.length; i++) {
        let c = str[i]
        charcounts[c] ? charcounts[c] += 1 : charcounts[c] = 1;
    }
    return charcounts;
}

function isAnagram(cc1, cc2) {
  cc1Keys = Object.keys(cc1);
  cc2Keys = Object.keys(cc2);
  if (cc1Keys.length != cc2Keys.length) {
    return false;
  }
  for (i = 0; i < cc1Keys.length; i++) {
    let key = cc1Keys[i]
    if (cc1[key] != cc2[key]) {
      return false;
    }
  }
  return true;
}

function prepare(categorized) {
    return Object.values(categorized.metals).map(function(metal) {
        return Object.values(categorized.nonmetals).map(function(nonmetal) {
            const charcounts = countChars(getSymbol(metal) + getSymbol(nonmetal))
            return {
                charcounts: charcounts,
                metal: metal.name,
                nonmetal: nonmetal.name
            }
        })
    }).flat();
}

function saltAnagrams(cc, prepared) {
    return prepared.filter(function(salt) {
        return isAnagram(cc, salt.charcounts);
    });
}

function main(categorized, prepared, phrase) {
    if (!phrase) {
        phrase = (window.location.hash.slice(1) || 'Salt');
    }

    const reduced = phrase.toLowerCase().replace(/[^a-z]/g, '')

    var content = phrase + "\n";
    var has_salt = false;

    saltAnagrams(countChars(reduced), prepared).forEach(function(salt) {
        if (has_salt) {
            content += '\n'
        }
        content += prettyPresent(categorized.metals[salt.metal]) + '\n';
        content += prettyPresent(categorized.nonmetals[salt.nonmetal]) + '\n'
        has_salt = true
    })

    if (!has_salt) {
        content += "No salts were found";
    }
    print(content);
}

function keyHandler(k) {
    if (k.key == 'Enter') {
        var input = document.getElementById('phrase');
        main(categorized, prepared, input.value);
        input.value = '';
    }
}

async function onLoad() {
    window.categorized = localStorage.getItem('categorized');
    window.prepared = localStorage.getItem('prepared');

    if (window.categorized) {
        window.categorized = JSON.parse(window.categorized);
    } else {
        console.log('Categorizing...');
        window.categorized = categorize(await fetchData());
        localStorage.setItem('categorized', JSON.stringify(window.categorized));
    }

    if (window.prepared) {
        window.prepared = JSON.parse(window.prepared);
    } else {
        console.log('Preparing...');
        window.prepared = prepare(categorized);
        localStorage.setItem('prepared', JSON.stringify(window.prepared));
    }
    document.getElementById('phrase').addEventListener('keypress',
                                                       keyHandler);
    main(categorized, prepared);
}
