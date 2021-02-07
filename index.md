<!-- ## Welcome to GitHub Pages

You can use the [editor on GitHub](https://github.com/whutddk/RiftCore/edit/gh-pages/index.md) to maintain and preview the content for your website in Markdown files.

Whenever you commit to this repository, GitHub Pages will run [Jekyll](https://jekyllrb.com/) to rebuild the pages in your site, from the content in your Markdown files.

### Markdown

Markdown is a lightweight and easy-to-use syntax for styling your writing. It includes conventions for

```markdown
Syntax highlighted code block

# Header 1
## Header 2
### Header 3

- Bulleted
- List

1. Numbered
2. List

**Bold** and _Italic_ and `Code` text

[Link](url) and ![Image](src)
```

For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).

### Jekyll Themes

Your Pages site will use the layout and styles from the Jekyll theme you have selected in your [repository settings](https://github.com/whutddk/RiftCore/settings). The name of this theme is saved in the Jekyll `_config.yml` configuration file.

### Support or Contact

Having trouble with Pages? Check out our [documentation](https://docs.github.com/categories/github-pages-basics/) or [contact support](https://github.com/contact) and we’ll help you sort it out.



------------------ -->

<script src="https://cdn.jsdelivr.net/npm/chart.js@2.9.2/dist/Chart.min.js"></script>
<script src="data/performance.js"></script>
<canvas id="myChart" width="400" height="400"></canvas>
<script>

var ctx = document.getElementById('myChart');
var labels = new Array();
var ds = new Array();
for (i in data["benchmark"])
{
  ds.push(data["benchmark"][i]["dhrystone"]);
  labels.push(data["benchmark"][i]["hash"]);
}

var myChart = new Chart(ctx, {
    type: 'line',
    data: {
        labels: labels,
        datasets: [{
            label: ["Dhrystone(DIPS/MHz)"],
            data: ds,
            borderColor: "rgba(0, 0, 0, 0.5)",
            backgroundColor: "rgba(0, 0, 200, 0.2)"
        }]
    },
  options: {
    responsive: true,
    title: {
      display: true,
      text: "Dhrystone of RiftCore"
    },
    tooltips: {
      mode: 'index',
      intersect: false,
    },
    hover: {
      mode: 'nearest',
      intersect: true
    },
    scales: {
      xAxes: [{
        display: true,
        scaleLabel: {
          display: true,
          labelString: 'Commit-id'
        }
      }],
      yAxes: [{
        display: true,
        scaleLabel: {
          display: true,
          labelString: 'Dhrystone(DIPS/MHz)'
        }
      }]
    },
    tooltips: {
              callbacks: {
                afterTitle: items => {
                  const {index} = items[0];
                  const info = data["benchmark"][index];
                  return '\n' + info["commit comment"]+ '\n' + info["author date"] + 'author by @' + info["author name"] + '\n';

                },
                label: item => {
                  let label = item.value;
                  label += ' DIPS/MHz'
                  return label;
                },
                // afterLabel: item => {
                //   // const { extra } = dataset[item.index].bench;
                //   return "668"
                //   // extra ? '\n' + extra : '';
                // }
              }
          },
  }
});
</script>

















