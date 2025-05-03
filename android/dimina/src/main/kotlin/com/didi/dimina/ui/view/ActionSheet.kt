package com.didi.dimina.ui.view

import android.content.res.Configuration
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.graphics.toColorInt
import kotlinx.coroutines.launch

/**
 * 通用底部功能菜单选择器
 * Author: Doslin
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ActionSheet(
    title: String = "", // Dialog title
    buttonLabelsColor: String = "#000000", // Button labels color
    buttonLabels: List<String>, // List of button labels
    onButtonClick: (Int) -> Unit, // Callback for button clicks, passing the index of the clicked button
    onDismiss: () -> Unit // Callback for dismissing the dialog
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true) // 跳过部分展开状态
    val scope = rememberCoroutineScope()
    
    ModalBottomSheet(
        onDismissRequest = { onDismiss() },
        sheetState = sheetState,
        shape = RoundedCornerShape(topStart = 16.dp),
        containerColor = Color.White,
        dragHandle = { },
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                , // Add padding at the bottom for better appearance
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
                // Title
                if (title.isNotEmpty()) {
                    Text(
                        text = title,
                        fontSize = 16.sp,
                        modifier = Modifier.padding(top = 16.dp),
                        textAlign = TextAlign.Center
                    )
                }

                // Dynamically render buttons based on the buttonLabels list
                buttonLabels.forEachIndexed { index, label ->
                    // Button text
                    Text(
                        text = label,
                        fontSize = 16.sp,
                        color =  Color(buttonLabelsColor.toColorInt()),
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable {
                                scope.launch {
                                    sheetState.hide() // Hide with animation
                                }.invokeOnCompletion {
                                    onButtonClick(index) // Call the callback with the index of the clicked button
                                }
                            }
                            .padding(vertical = 12.dp),
                        textAlign = TextAlign.Center
                    )

                    // Add a divider after each button except the last one
                    if (index < buttonLabels.size - 1) {
                        HorizontalDivider(color = Color(0xFFF0F0F0), thickness = 1.dp)
                    }
                }

                // Divider before the Cancel button
                HorizontalDivider(color = Color(0xFFF7F7F7), thickness = 4.dp)

                // Cancel button
                Text(
                    text = "取消",
                    fontSize = 16.sp,
                    color = Color.Black,
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable {
                            scope.launch {
                                sheetState.hide() // Hide with animation
                            }.invokeOnCompletion {
                                onDismiss() // Then dismiss
                            }
                        }
                        .padding(vertical = 12.dp),
                    textAlign = TextAlign.Center
                )
            }
        }
    }

@Preview(showBackground = true, uiMode = Configuration.UI_MODE_NIGHT_NO)
@Composable
fun ChooseDialogPreview() {
    ActionSheet(
        buttonLabels = listOf("拍摄", "从相册选择"), // Example button labels
        onButtonClick = { index ->
            println("Button clicked: $index")
        },
        onDismiss = {
            println("Dialog dismissed")
        }
    )
}

