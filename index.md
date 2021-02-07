# RiftCore

![License](https://img.shields.io/github/license/whutddk/RiftCore)



--------------------------------------------

RiftCore is a 9-stage, multi-issue, out of order 64-bits RISC-V Core, which supports RV64IMC.

![architecture](https://github.com/whutddk/RiftCore/raw/master/doc/riftCore%20micro-architecture.png)



### [Wiki Here](https://github.com/whutddk/RiftCore/wiki)
### [Wiki-zh Here](https://gitee.com/whutddk/rift-core/wikis/)


------------------------------------

## Status

|Last Commit|![GitHub last commit](https://img.shields.io/github/last-commit/whutddk/RiftCore)|Status|![GitHub Workflow Status](https://img.shields.io/github/workflow/status/whutddk/RiftCore/CI)|Support ISA|![ISA](https://img.shields.io/badge/ISA-RV64IMC-yellowgreen)|
| --- | --- | --- | --- | --- | --- |
|![ISA](https://img.shields.io/badge/ISA-RV64I-yellowgreen)|
|![rv64ui-p-add](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-add.json)|![rv64ui-p-addiw](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-addiw.json)|![rv64ui-p-addw](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-addw.json)|![rv64ui-p-and](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-and.json)|![rv64ui-p-andi](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-andi.json)|![rv64ui-p-auipc](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-auipc.json)|
|![rv64ui-p-beq](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-beq.json)|![rv64ui-p-bge](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-bge.json)|![rv64ui-p-bgeu](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-bgeu.json)|![rv64ui-p-blt](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-blt.json)|![rv64ui-p-bltu](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-bltu.json)|![rv64ui-p-bne](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-bne.json)|
|![rv64ui-p-jal](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-jal.json)|![rv64ui-p-jalr](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-jalr.json)|![rv64ui-p-lb](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-lb.json)|![rv64ui-p-lbu](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-lbu.json)|![rv64ui-p-ld](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-ld.json)|![rv64ui-p-lh](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-lh.json)|
|![rv64ui-p-lhu](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-lhu.json)|![rv64ui-p-lui](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-lui.json)|![rv64ui-p-lw](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-lw.json)|![rv64ui-p-lwu](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-lwu.json)|![rv64ui-p-or](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-or.json)|![rv64ui-p-ori](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-ori.json)|
|![rv64ui-p-sb](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-sb.json)|![rv64ui-p-sd](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-sd.json)|![rv64ui-p-sh](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-sh.json)|![rv64ui-p-sll](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-sll.json)|![rv64ui-p-slli](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-slli.json)|![rv64ui-p-slliw](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-slliw.json)|
|![rv64ui-p-sllw](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-sllw.json)|![rv64ui-p-slt](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-slt.json)|![rv64ui-p-slti](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-slti.json)|![rv64ui-p-sltiu](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-sltiu.json)|![rv64ui-p-sltu](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-sltu.json)|![rv64ui-p-sra](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-sra.json)|
|![rv64ui-p-srai](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-srai.json)|![rv64ui-p-sraiw](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-sraiw.json)|![rv64ui-p-sraw](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-sraw.json)|![rv64ui-p-srl](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-srl.json)|![rv64ui-p-srli](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-srli.json)|![rv64ui-p-srliw](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-srliw.json)|
|![rv64ui-p-srlw](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-srlw.json)|![rv64ui-p-sub](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-sub.json)|![rv64ui-p-subw](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-subw.json)|![rv64ui-p-sw](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-sw.json)|![rv64ui-p-xor](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-xor.json)|![rv64ui-p-xori](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-xori.json)|
|![rv64mi-p-access](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64mi-p-access.json)|![rv64mi-p-breakpoint](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64mi-p-breakpoint.json)|![rv64mi-p-csr](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64mi-p-csr.json)|![rv64mi-p-ma_addr](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64mi-p-ma_addr.json)|![rv64mi-p-ma_fetch](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64mi-p-ma_fetch.json)|![rv64mi-p-mcsr](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64mi-p-mcsr.json)|
|![rv64ui-p-fence_i](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-fence_i.json)|![rv64ui-p-simple](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64ui-p-simple.json)|![rv64mi-p-illegal](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64mi-p-illegal.json)|
|![ISA](https://img.shields.io/badge/ISA-RV64C-yellowgreen)|
|![rv64uc-p-rvc](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64uc-p-rvc.json)|
|![ISA](https://img.shields.io/badge/ISA-RV64M-yellowgreen)|
|![rv64um-p-mul](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64um-p-mul.json)|![rv64um-p-mulh](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64um-p-mulh.json)|![rv64um-p-mulhsu](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64um-p-mulhsu.json)|![rv64um-p-mulhu](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64um-p-mulhu.json)|![rv64um-p-mulw](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64um-p-mulw.json)|![rv64um-p-div](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64um-p-div.json)|
|![rv64um-p-divu](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64um-p-divu.json)|![rv64um-p-divuw](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64um-p-divuw.json)|![rv64um-p-divw](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64um-p-divw.json)|![rv64um-p-rem](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64um-p-rem.json)|![rv64um-p-remu](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64um-p-remu.json)|![rv64um-p-remuw](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64um-p-remuw.json)|
|![rv64um-p-remw](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Frv64um-p-remw.json)|


------------------------------------

## Benchmark

![dhrystone](https://img.shields.io/endpoint?style=plastic&url=https%3A%2F%2Fraw.githubusercontent.com%2Fwhutddk%2FRiftCore%2Fgh-pages%2Fdata%2Fdhrystone.json)




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




------------------------------------

## Sponsorships

![BTC](https://img.shields.io/badge/BTC-124egseDMD983etDrsAzUnXvi6twpWtjLd-orange)
![LTC](https://img.shields.io/badge/LTC-LakQ8AL2JeLGKmjanYrpq6Hq7fW4NySXYA-green)
![ETH](https://img.shields.io/badge/ETH-0x2f8aeb5f9dfe2936632f47363a42d7f71810c62b-lightgrey)
![DOGE](https://img.shields.io/badge/DOGE-DJSv3BgtfPtjc3LzL5PaooAvs9xn8n4tbX-blue)
![XMR](https://img.shields.io/badge/XMR-43xzb6WgP7gNRDj9WDzCAybFCfNSXbAZsdkzfYQZw5eF83bFpsFDq7T4HA8wkRdP9oJ3wrEPbWA1F6s3odsAwtUPSVZpPfW-yellow)






















