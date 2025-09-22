package sign

import (
	"fmt"
)

// SignRequest signs a request
func SignRequest(data string) string {
	fmt.Printf("Signing request: %s\n", data)
	// TODO: Implement actual signing logic
	return "signed_" + data
}
