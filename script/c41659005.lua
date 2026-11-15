--唱晓新月的三相歌
local s,id,o=GetID()
function s.initial_effect(c)
	--自己的额外卡组（表侧）有「唱晓」怪兽3只以上，可以从手卡发动
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,3))
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e0:SetCondition(s.handcon)
	c:RegisterEffect(e0)
	--①：发动后变成效果怪兽特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.trapmonstg)
	e1:SetOperation(s.trapmonsop)
	c:RegisterEffect(e1)
	--●：双方回合，让墓地·除外·额外（表侧）3张「结羽」卡回到卡组
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id+o,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCost(s.jycost)
	e2:SetTarget(s.jytg)
	e2:SetOperation(s.jyop)
	c:RegisterEffect(e2)
    --②：墓地这张卡和额外（表侧）1只「结羽」怪兽除外
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.cost2)
	e3:SetOperation(s.op2)
	c:RegisterEffect(e3)
end
function s.exfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe99) and c:IsType(TYPE_MONSTER)
end
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(s.exfilter,tp,LOCATION_EXTRA,0,3,nil)
end
--①
function s.trapmonstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,900,2800,9,RACE_SPELLCASTER,ATTRIBUTE_WIND) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.trapmonsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPES_EFFECT_TRAP_MONSTER,900,2800,9,RACE_SPELLCASTER,ATTRIBUTE_WIND) then return end
	c:AddMonsterAttribute(TYPE_EFFECT,ATTRIBUTE_WIND,RACE_SPELLCASTER,9,900,2800)
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)
end
--●
function s.jyfilter(c)
	if c:IsLocation(LOCATION_EXTRA) and not c:IsFaceup() then return false end
	return c:IsSetCard(0xe99)
end
function s.jycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.jyfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_EXTRA,0,nil)
	if chk==0 then return g:GetCount()>=3 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:Select(tp,3,3,nil)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function s.jytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttack()>=800 end
end
function s.jyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	Duel.Draw(tp,1,REASON_EFFECT)
end
--②
function s.jyexfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe99) and c:IsType(TYPE_MONSTER)
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost()
			and Duel.IsExistingMatchingCard(s.jyexfilter,tp,LOCATION_EXTRA,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.jyexfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()==0 then return end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc then return end
	local code=tc:GetCode()
	--「结羽」怪兽在额外卡组（表侧）发动的效果（回手后的部分）
	local f=_G.KETSUBA_EXTRA_EFFECTS and _G.KETSUBA_EXTRA_EFFECTS[code]
	if f==nil then
		pcall(Duel.LoadScript,"c"..tostring(code)..".lua")
		f=_G.KETSUBA_EXTRA_EFFECTS and _G.KETSUBA_EXTRA_EFFECTS[code]
	end
	if type(f)=='function' then f(e,tp,tc) end
end
