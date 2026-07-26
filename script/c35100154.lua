--异质绝望 烟蛇太郎
function c35100154.initial_effect(c)
--spsummon
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(35100154,0))
e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
e1:SetType(EFFECT_TYPE_IGNITION)
e1:SetRange(LOCATION_HAND)
e1:SetCountLimit(1,35100154)
e1:SetCost(c35100154.spcost)
e1:SetTarget(c35100154.sptg)
e1:SetOperation(c35100154.spop)
c:RegisterEffect(e1)
--set
local e2=Effect.CreateEffect(c)
e2:SetDescription(aux.Stringid(35100154,1))
e2:SetCategory(CATEGORY_HANDES)
e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
e2:SetCode(EVENT_SPSUMMON_SUCCESS)
e2:SetProperty(EFFECT_FLAG_DELAY)
e2:SetCountLimit(1,35100155)
e2:SetTarget(c35100154.settg)
e2:SetOperation(c35100154.setop)
c:RegisterEffect(e2)
local e3=e2:Clone()
e3:SetCode(EVENT_FLIP)
c:RegisterEffect(e3)
--disable spsummon
local e4=Effect.CreateEffect(c)
e4:SetType(EFFECT_TYPE_FIELD)
e4:SetRange(LOCATION_MZONE)
e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
e4:SetTargetRange(1,0)
e4:SetTarget(c35100154.sumlimit)
c:RegisterEffect(e4)
end
function c35100154.cfilter(c)
	return c:IsSetCard(0xa91) and (c:IsType(TYPE_SPELL) or (c:IsType(TYPE_MONSTER)
	 and not c:IsAttribute(ATTRIBUTE_EARTH))) and c:IsAbleToRemoveAsCost()
end
function c35100154.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c35100154.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c35100154.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c35100154.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c35100154.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c35100154.cfilter2(c)
	return c:IsAttribute(ATTRIBUTE_WATER+ATTRIBUTE_LIGHT) and c:IsFaceup() and c:IsSetCard(0xa91)
end
function c35100154.setfilter(c)
	return c:IsSetCard(0xa91) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function c35100154.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c35100154.setfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function c35100154.setop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c35100154.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SSet(tp,tc)~=0 then
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(35100154,2))
		  e1:SetType(EFFECT_TYPE_SINGLE)
		  e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		  e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetCondition(c35100154.actcon)
		  e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		  tc:RegisterEffect(e1)
	end
end
function c35100154.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c35100154.cfilter2,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function c35100154.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:GetRace()~=RACE_WARRIOR
end
