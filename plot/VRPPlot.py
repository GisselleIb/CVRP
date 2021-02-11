import matplotlib.pyplot as plt
import statistics as st


"""Funciones auxiliares utilizadas para graficar los resultados de las ejecuciones"""

def plotEvolution(data,instance, labelY = 'Función Objetivo', labelX = 'Iteraciones', legends=["Mejor solución", "Solución Actual"]):
    iteraciones = range(len(data))
    solucionActual = []
    mejorSolucion = []
    tiempo = []
    for i in data:
        solucionActual.append(i[0])
        mejorSolucion.append(i[1])
        tiempo.append(i[2])
    plt.plot(iteraciones, solucionActual,iteraciones,  mejorSolucion)
    plt.xlabel(labelX)
    plt.ylabel(labelY)
    plt.title(instance)
    plt.legend(legends, loc=1)
    plt.show()

def plotAverage(log,instance,temperature):
    data = []
    for k in range(len(log)):
        logTemp = log[k]
        averages = [0] * len(logTemp[0])

        for solution in logTemp:
            for j in range(len(solution)):
                averages[j] += solution[j][1]
        for i in range(len(averages)):
            averages[i] = averages[i] / len(logTemp)
        data.append(averages)

    legends=[]
    for t in temperature:
        legends.append('Temperatura '+str(t))


    plt.plot(data[0], 'g--', data[1], 'b--',data[2],'r--',data[3],'y--',data[4],'c--' )
    plt.legend(legends, loc=1)
    plt.title(instance)
    plt.xlabel('Iteraciones')
    plt.ylabel('Mejor solución promedio')
    plt.show()

def plotBoxPlot(data,instance,temperature):
    fig,ax=plt.subplots()
    ax.set_title("Soluciones para la instancia "+instance)
    plt.boxplot(data,labels=temperature)
    plt.show()



i=0
l=[]
with open("result-n60-k9.txt") as data:
    for line in data:
        #if i > 200:
        #    break
        line=line.strip()
        values=line.split(' ')
        l.append([float(values[0]), float(values[1]), i])
        i=i+1

plotEvolution(l,"Instancia A-n60-k9")
