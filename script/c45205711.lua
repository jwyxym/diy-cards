--铁鳞之水手长-鱼人胡克
local s,id=GetID()
function s.initial_effect(c)
	--超量召唤：水属性2星怪兽×2
	aux.AddXyzProcedure(c,s.matfilter,2,2)
	c:EnableReviveLimit()
	
	--① 主要阶段，取除1个超量素材，以下效果各自适用
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	
	--② 守备表示的这张卡不会被效果·战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	
	--③ 双方的回合，自己场上有「铁鳞」怪兽的场合，解放自己场上1只水族怪兽，选对方场上1只怪兽为对象才能发动。这张卡从墓地特殊召唤，那只怪兽变成里侧守备表示。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e4:SetCountLimit(1,id+100)
	e4:SetCondition(s.spcon)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end

-- 超量素材：水属性2星怪兽
function s.matfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevel(2)
end

--① cost：取除1个超量素材
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end

--① 目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end

--① 处理
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从卡组·墓地把1只4星以下「铁鳞海贼团」怪兽守备表示特召
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	-- 从卡组·墓地把1张「铁鳞」魔法·陷阱卡加入手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g2>0 then
		Duel.BreakEffect()
		Duel.SendtoHand(g2,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g2)
	end
	-- 自肃：这个回合只能从额外卡组特召「铁鳞」怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end

-- 特召过滤：4星以下「铁鳞海贼团」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1F7A) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

-- 检索过滤：「铁鳞」魔法·陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x1F7A) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

-- 自肃
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x1F7A)
end

--② 条件：守备表示
function s.indcon(e)
	local c=e:GetHandler()
	return c:IsDefensePos()
end

--③ 条件：自己场上有「铁鳞」怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.fconfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.fconfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1F7A)
end

--③ cost：解放自己场上1只水族怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.relfilter,1,nil) end
	local g=Duel.SelectReleaseGroup(tp,s.relfilter,1,1,nil)
	Duel.Release(g,REASON_COST)
end

function s.relfilter(c)
	return c:IsRace(RACE_AQUA) and c:IsReleasable()
end

--③ 目标：选对方场上1只怪兽
function s.postgfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.postgfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(s.postgfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.postgfilter,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end

--③ 处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
end

return s
