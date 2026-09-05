-- No.102 圣光天使 辉环 (ID: 20263241)
local s,id,o=GetID()
local SET_STAR_SERAPH=0x86 -- 「光天使」官方字段代码
local SET_SEVENTH=0x175     -- 「七皇」官方字段代码

function s.initial_effect(c)
	-- Xyz 召唤手续：光属性4星怪兽 × 3
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),4,3)
	c:EnableReviveLimit()

	-- ①：特殊召唤成功的场合：卡组检索1张「光天使」卡和1张「七皇」魔陷，额外光属性自肃 (HOPT: id)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- ②：自己·对方回合，去除1个超量素材，以场上1只攻击表示怪兽为对象：对方可支付2000LP无效，否则无效并破坏 (HOPT: id+o*100)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o*100)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)

	-- ③：送去墓地的场合：三选一特召「光天使」怪兽（各分支1回合各1次）
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetTarget(s.sptg3)
	e3:SetOperation(s.spop3)
	c:RegisterEffect(e3)
end

-- ==================== ① 效果：特召双检索 + 额外光属性自肃 ====================
function s.thfilter1(c)
	return c:IsSetCard(SET_STAR_SERAPH) and c:IsAbleToHand()
end

function s.thfilter2(c)
	return c:IsSetCard(SET_SEVENTH) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
			and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end

function s.splimit_light(e,c,sump,sumtype,sumpos,target_p,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.thfilter1,tp,LOCATION_DECK,0,nil)
	local g2=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_DECK,0,nil)
	if #g1==0 or #g2==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg1=g1:Select(tp,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg2=g2:Select(tp,1,1,nil)
	sg1:Merge(sg2)
	if #sg1==2 and Duel.SendtoHand(sg1,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,sg1)
	end

	-- 这个回合，自己不是光属性怪兽不能从额外卡组特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,6)) -- 只能从额外卡组特殊召唤光属性怪兽
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit_light)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

-- ==================== ② 效果：二速剥除素材 + 对方抉择支付/无效破坏 ====================
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end

function s.atkfilter(c)
	return c:IsAttackPos()
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	-- 对方可以支付 2000 基本分让这个效果无效
	if Duel.CheckLPCost(1-tp,2000) and Duel.SelectYesNo(1-tp,aux.Stringid(id,7)) then
		Duel.PayLPCost(1-tp,2000)
		return
	end
	-- 没有支付的场合，作为对象的怪兽效果无效并破坏
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		Duel.AdjustInstantly()
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

-- ==================== ③ 效果：送墓三选一特召（各分支1回合各1次） ====================
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_STAR_SERAPH) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spfilter_banished(c,e,tp)
	return c:IsFaceup() and s.spfilter(c,e,tp)
end

function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local b1=ft>0 and Duel.GetFlagEffect(tp,id+o*200)==0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local b2=ft>0 and Duel.GetFlagEffect(tp,id+o*300)==0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	local b3=ft>0 and Duel.GetFlagEffect(tp,id+o*400)==0
		and Duel.IsExistingMatchingCard(s.spfilter_banished,tp,LOCATION_REMOVED,0,1,nil,e,tp)

	if chk==0 then return b1 or b2 or b3 end

	local options={}
	local ops={}
	if b1 then table.insert(options,aux.Stringid(id,3)); table.insert(ops,1) end
	if b2 then table.insert(options,aux.Stringid(id,4)); table.insert(ops,2) end
	if b3 then table.insert(options,aux.Stringid(id,5)); table.insert(ops,3) end

	local sel=Duel.SelectOption(tp,table.unpack(options))
	local op=ops[sel+1]
	e:SetLabel(op)

	-- 注册分支使用标记，确保该分支1回合只能使用1次
	Duel.RegisterFlagEffect(tp,id+(op+1)*100,RESET_PHASE+PHASE_END,0,1)

	local loc=LOCATION_HAND
	if op==2 then loc=LOCATION_GRAVE end
	if op==3 then loc=LOCATION_REMOVED end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end

function s.spop3(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local op=e:GetLabel()
	local g=nil
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	elseif op==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=Duel.SelectMatchingCard(tp,s.spfilter_banished,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	end
	if g and #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end