interface TipProvider{
    tips:string[][]
}
export default function TipProvider({tips}: TipProvider){
      return(
          <div>
              <h2 className="text-2xl font-bold text-[#217C6A] mb-4">{tips[0]}</h2>
              <ul className="list-disc pl-5 space-y-2">
                {tips[1].map((insight, index) => (
                  <li key={index} className="text-gray-700 shadow-sm rounded p-2 hover:translate-x-1 transition-all ">{insight}</li>
                ))}
              </ul>
              <div className="mt-6 p-4 bg-gray-100 rounded-lg">
                <h3 className="font-semibold text-[#217C6A]">{tips[2][0]}</h3>
                <p className="mt-2 ">{tips[2][1]}</p>
              </div>
            </div>           )
}