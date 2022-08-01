// Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License"). You may
// not use this file except in compliance with the License. A copy of the
// License is located at
//
//     http://aws.amazon.com/apache2.0/
//
// or in the "license" file accompanying this file. This file is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing
// permissions and limitations under the License.

package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"

	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
)

var port string
var redirectURL string

func init() {
	port = "8082"
	redirectURL = os.Getenv("LOGOUT_URL")

}

// LogoutHandler expires ALB Cookies and redirects to Cognito Logout Endpoint
func LogoutHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("Traffic reached LogoutHandler")

	// There are 4 possible AWSELBAuthSessionCookies
	// https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html#authentication-logout
	for cookieIndex := 0; cookieIndex < 4; cookieIndex++ {
		name := fmt.Sprintf("AWSELBAuthSessionCookie-%s", strconv.Itoa(cookieIndex))
		expireALBCookie := &http.Cookie{Value: "Expired", Name: name, MaxAge: -1, Path: "/"}
		http.SetCookie(w, expireALBCookie)
	}
	http.Redirect(w, r, redirectURL, http.StatusSeeOther)
}

func main() {

	router := mux.NewRouter()
	router.HandleFunc("/logout", LogoutHandler).Methods(http.MethodGet)

	var listenPort = ":" + port
	log.Println("Starting web server at", listenPort)
	log.Fatal(http.ListenAndServe(listenPort, handlers.CORS()(router)))
}
