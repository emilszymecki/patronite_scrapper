async function getMembersData(page, args) {
    return page.evaluate(args => {
        return [...document.querySelectorAll(".carousel-cell")].map((x) => {
            let tags = x.querySelector(".card__content--tags"),
            name = x.querySelector(".card__content--name").innerText.replace(/['"]+/g, ''),
            numbers = [...x.querySelectorAll(".card__content--numbers div")],
            tags_format = tags ? tags.innerText.replaceAll('\n',',') : '',
            patrons = numbers[0] ? numbers[0].querySelector("span").innerText : "FALSE",
            month_amount = numbers[1] ? numbers[1].querySelector("span").innerText : "FALSE",
            total_amount = numbers[2] ? numbers[2].querySelector("span").innerText : "FALSE";
  
            return ({
              tags: tags_format,
              name:name,
              patrons: patrons,
              month_amount: month_amount,
              total_amount: total_amount,
            });
          });
    },args);
  }
  exports.__esModule = true;
  exports.getMembersData = getMembersData;