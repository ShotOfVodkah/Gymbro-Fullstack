import Foundation

import GymbroNetwork

public protocol WorkoutsNetworkClient {
    func fetchWorkoutsDivJson() -> Data
}

final class WorkoutsNetworkClientStub: WorkoutsNetworkClient {

    init() {}
//    init(networkClient: NetworkClient) {
//        self.networkClient = networkClient
//    }

    func fetchWorkoutsDivJson() -> Data {
        let workouts = ["Chest Day", "Legs", "Back & Biceps", "Cardio"]

        let itemsJson = workouts.map { name in
            let jsonName = escapeJson(name)

            // app:// для client-side sheet (обычный тап)
            let encodedNameForUrl = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name
            let url = "app://open_workout?name=\(encodedNameForUrl)"
            let escapedUrl = escapeJson(url)

            // ВАЖНО:
            // 1) без "@{...}" здесь — это только кусок выражения
            // 2) строки в выражениях в одинарных кавычках
            let exprName = escapeExprStringLiteral(name) // для выражения
            let isSelectedExpr = "selected_workout == '\(exprName)'"

            return """
            {
              "type": "text",
              "text": "\(jsonName)",
              "font_size": 16,
              "margins": { "top": 8, "left": 16, "right": 16 },
              "paddings": { "top": 8, "bottom": 8, "left": 12, "right": 12 },

              "text_color": "@{\(isSelectedExpr) ? '#FF000000' : '#FF666666'}",

              "background": [
                {
                  "type": "solid",
                  "color": "@{\(isSelectedExpr) ? '#FFE6F0FF' : '#00000000'}"
                }
              ],

              "actions": [
                {
                  "log_id": "open_workout",
                  "url": "\(escapedUrl)"
                }
              ],

              "longtap_actions": [
                {
                  "log_id": "select_workout",
                  "set_variable": {
                    "name": "selected_workout",
                    "value": "\(jsonName)"
                  }
                }
              ]
            }
            """
        }.joined(separator: ",")

        let json = """
        {
          "card": {
            "log_id": "workouts_list",
            "variables": [
              { "name": "selected_workout", "type": "string", "value": "" }
            ],
            "states": [
              {
                "state_id": 0,
                "div": {
                  "type": "container",
                  "orientation": "vertical",
                  "items": [
                    {
                      "type": "text",
                      "text": "Workouts",
                      "font_size": 22,
                      "margins": { "top": 16, "left": 16, "right": 16, "bottom": 8 }
                    },
                    \(itemsJson)
                  ]
                }
              }
            ]
          }
        }
        """

        return Data(json.utf8)
    }

    private func escapeJson(_ s: String) -> String {
        s
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
    }

    /// Экранирование строки *внутри выражения DivKit*:
    /// в expressions строковые литералы в одинарных кавычках,
    /// а одинарная кавычка внутри литерала экранируется удвоением: '' (две кавычки).
    private func escapeExprStringLiteral(_ s: String) -> String {
        s.replacingOccurrences(of: "'", with: "''")
    }


//    let networkClient: NetworkClient
}
