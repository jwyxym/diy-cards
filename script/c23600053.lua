-- 莫扎特·沃尔夫冈 (ID: 23600053)
local s,id,o=GetID()
function s.initial_effect(c)
	-- 同调召唤手续：风属性调整＋调整以外的魔法师族·风属性怪兽1只
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND),s.ntfilter,1,1)
	c:EnableReviveLimit()

	-- 这张卡不用同调召唤不能从额外卡组特殊召唤
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)

	-- ①：同调召唤成功的场合，以墓地·除外的1只魔法师族·风属性怪兽为对象发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tdcon)
	e1:SetCost(s.oathcost)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)

	-- ②：墓地·除外状态存在，场上的魔法师族·风属性同调怪兽因对方离场的场合发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e2:SetCountLimit(1,id+o*100)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.oathcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)

	-- 全局计数注册：监听全回合非风属性怪兽的召唤·特殊召唤
	Duel.AddCustomActivityCounter(id,ACTIVITY_SUMMON,s.counterfilter)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end

-- 非调整素材过滤：魔法师族·风属性
function s.ntfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
end

-- 额外卡组特召限制
function s.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.synlimit(e,se,sp,st)
end

-- 全局风属性计数器过滤
function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND)
end

-- 誓约代价检查与施加
function s.oathcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SUMMON)==0
		and Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	Duel.RegisterEffect(e2,tp)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,target_p,se)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end

-- ①效果：同调召唤成功条件
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end

-- ①效果：手卡·墓地特召对象过滤（原本等级比目标更低）
function s.spfilter(c,e,tp,lv)
	local clv=c:GetOriginalLevel()
	return clv>0 and clv<lv and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- ①效果：墓地·除外回到卡组目标过滤
function s.tdfilter(c,e,tp)
	local lv=c:GetOriginalLevel()
	return lv>0 and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c,e,tp,lv)
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local lv=tc:GetOriginalLevel()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

-- ②效果：场上风属性魔法师族同调怪兽离场过滤
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP)
		and c:GetPreviousTypeOnField()&TYPE_SYNCHRO~=0
		and c:GetPreviousRaceOnField()&RACE_SPELLCASTER~=0
		and c:GetPreviousAttributeOnField()&ATTRIBUTE_WIND~=0
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp))
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 必须在墓地或表侧除外，且自身并非刚从场上离开的那只怪兽（避免时序冲突）
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
		and eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(c)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_ONFIELD)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local sg=g:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end