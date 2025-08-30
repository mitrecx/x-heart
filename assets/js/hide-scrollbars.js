// 强制隐藏代码块中的滚动条
document.addEventListener('DOMContentLoaded', function() {
    // 隐藏所有代码块的滚动条
    function hideScrollbars() {
        // 查找所有代码块元素
        const codeBlocks = document.querySelectorAll('.post-content pre, .post-content .highlight, .post-content .highlighttable');
        
        codeBlocks.forEach(function(block) {
            // 设置CSS样式
            block.style.setProperty('scrollbar-width', 'none', 'important');
            block.style.setProperty('-ms-overflow-style', 'none', 'important');
            
            // 查找内部的code元素
            const codeElements = block.querySelectorAll('code');
            codeElements.forEach(function(code) {
                code.style.setProperty('scrollbar-width', 'none', 'important');
                code.style.setProperty('-ms-overflow-style', 'none', 'important');
            });
        });
        
        // 使用CSS-in-JS方式添加样式
        const style = document.createElement('style');
        style.textContent = `
            .post-content pre::-webkit-scrollbar,
            .post-content pre code::-webkit-scrollbar,
            .post-content .highlight::-webkit-scrollbar,
            .post-content .highlight pre::-webkit-scrollbar,
            .post-content .highlight pre code::-webkit-scrollbar,
            .post-content .highlighttable::-webkit-scrollbar,
            .post-content .highlighttable td::-webkit-scrollbar,
            .post-content .highlighttable td .highlight::-webkit-scrollbar,
            .post-content .highlighttable td .highlight pre::-webkit-scrollbar,
            .post-content .highlighttable td .highlight pre code::-webkit-scrollbar {
                display: none !important;
                width: 0 !important;
                height: 0 !important;
            }
        `;
        document.head.appendChild(style);
    }
    
    // 立即执行
    hideScrollbars();
    
    // 监听动态内容变化
    const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            if (mutation.type === 'childList') {
                hideScrollbars();
            }
        });
    });
    
    // 观察整个文档
    observer.observe(document.body, {
        childList: true,
        subtree: true
    });
});
