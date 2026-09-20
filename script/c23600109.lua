-- 创炎歧形-和煦二叉 (ID: 23600109)
local s,id,o=GetID()
function s.initial_effect(c)
	-- 连接标记与召唤手续：Link-2 (↙ ↓)
	-- 素材要求：「创炎」怪兽2只（支持魔陷区炎属性怪兽替代）
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,2,2,s.lcheck)

	-- 召唤规则：这张卡连接召唤的场合，可以让自己魔法与陷阱区域的炎属性怪兽当作连接素材使用
	-- 1. 赋予魔陷区的炎属性怪兽临时怪兽属性（确保通过 ocgcore 底层连接素材类型校验）
	local e0_1=Effect.CreateEffect(c)
	e0_1:SetType(EFFECT_TYPE_FIELD)
	e0_1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0_1:SetCode(EFFECT_ADD_TYPE)
	e0_1:SetRange(LOCATION_EXTRA)
	e0_1:SetTargetRange(LOCATION_SZONE,0)
	e0_1:SetTarget(s.matsztarget)
	e0_1:SetValue(TYPE_MONSTER)
	c:RegisterEffect(e0_1)

	-- 2. 注册额外连接素材适用范围
	local e0_2=Effect.CreateEffect(c)
	e0_2:SetType(EFFECT_TYPE_FIELD)
	e0_2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0_2:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e0_2:SetRange(LOCATION_EXTRA)
	e0_2:SetTargetRange(LOCATION_SZONE,0)
	e0_2:SetTarget(s.matsztarget)
	e0_2:SetValue(s.matval)
	c:RegisterEffect(e0_2)

	-- 召唤誓约限制：把这张卡连接召唤的回合，自己不是炎属性怪兽不能召唤·特殊召唤
	-- 1. 连接召唤成功时注册后续封锁
	local e0_3=Effect.CreateEffect(c)
	e0_3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0_3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0_3:SetCondition(s.regcon)
	e0_3:SetOperation(s.regop)
	c:RegisterEffect(e0_3)

	-- ①：这张卡连接召唤的场合，把这张卡当作永续魔法卡放置，以自己墓地·除外状态的1只「创炎」怪兽为对象才能发动。放置到魔陷区
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id) -- 1效果 HOPT
	e1:SetCondition(s.plcon)
	e1:SetCost(s.plcost)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)

	-- ②：这张卡从魔法与陷阱区域特殊召唤的场合，以自己墓地·除外状态最多2张「创炎」卡为对象才能发动。加入手卡或回到卡组
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o*100) -- 2效果 HOPT (遵循防撞车规范 id+o*100)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	-- 全局全回合召唤动作监听（用于连接召唤前的出场合法性前置拦截）
	if not s.global_check then
		s.global_check=true
		Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,s.counterfilter)
		Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
	end
end

-- 召唤活动计数器：仅记录非炎属性的召唤/特召
function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE)
end

-- 连接素材过滤
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0xd85) or (c:IsLocation(LOCATION_SZONE) and (c:IsAttribute(ATTRIBUTE_FIRE) or c:GetOriginalAttribute()&ATTRIBUTE_FIRE~=0))
end

-- 连接前置自肃检查：如果本回合已召唤/特召过非炎属性怪兽，则不可连接召唤此卡
function s.lcheck(g,lc,tp)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
end

-- 魔陷区可用素材过滤
function s.matsztarget(e,c)
	return c:IsFaceup() and c:GetOriginalType()&TYPE_MONSTER~=0
		and (c:IsAttribute(ATTRIBUTE_FIRE) or c:GetOriginalAttribute()&ATTRIBUTE_FIRE~=0)
end

function s.matval(e,lc,mg,c,tp)
	if lc==e:GetHandler() then
		return true, true
	else
		return false, false
	end
end

-- 成功连接召唤后施加的全回合炎属性自肃
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,target_p,se)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end

-- ==================== ① 效果：自身置入魔陷并拉取怪兽放置 ====================
function s.plcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

function s.pltgfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xd85) and c:IsType(TYPE_MONSTER)
end

function s.plcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 刚性判定：魔陷区必须有足够空位，且自身必须能作为永续魔法放置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>=2 and not c:IsForbidden() end
	Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
end

function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.pltgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.pltgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectTarget(tp,s.pltgfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
end

function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end

-- ==================== ② 效果：从魔陷特召回收「创炎」卡 ====================
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end

function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xd85) and (c:IsAbleToHand() or c:IsAbleToDeck())
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 修正：使用原生 ocgcore 的 CHAININFO_TARGET_CARDS 获取对象组，彻底根除 GetTargetCards 报错
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if #tg==0 then return end
	local b1=tg:FilterCount(Card.IsAbleToHand,nil)>0
	local b2=tg:FilterCount(Card.IsAbleToDeck,nil)>0
	if not (b1 or b2) then return end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,3))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,4))+1
	end
	if op==0 then
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tg)
	else
		Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end