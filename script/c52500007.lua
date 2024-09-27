--潜军突击
local s,id,o=GetID()
Duel.LoadScript("Sneak.lua")
function s.initial_effect(c)
	--Spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--sset
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id*2)
	e2:SetCondition(s.sscon)
	e2:SetTarget(s.sstg)
	e2:SetOperation(s.ssop)
	c:RegisterEffect(e2)
end
function s.spfi(c,e,tp)
	return (c:IsSetCard(0x520) or c:IsType(TYPE_FLIP)) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,0,0,POS_FACEDOWN_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfi,tp,LOCATION_DECK,0,1,nil,e,tp)
						and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.flfi(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,s.spfi,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #sg and Duel.SpecialSummon(sg,0,tp,tp,0,0,POS_FACEDOWN_DEFENSE) then
		Duel.ConfirmCards(1-tp,sg)
		if Duel.IsExistingMatchingCard(s.flfi,tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			local g=Duel.GetMatchingGroup(s.flfi,tp,LOCATION_MZONE,0,nil)
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	end
end
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return rp==tp and rc:IsOnField() and rc:IsType(TYPE_XYZ) and rc:IsSetCard(0x520)
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<1 then return end
	local c=e:GetHandler()
	if c and c:IsRelateToEffect(e) then
		Duel.SSet(tp,c)
	end
end
