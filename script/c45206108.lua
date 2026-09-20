--子陵
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ILLUSION),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	
	--①效果：这张卡特殊召唤的场合才能发动。把墓地的1张「古朝挽歌」魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	
	--②效果：怪兽的效果发动时才能发动。那个效果无效。无效的是自己场上的怪兽的情况，从自己的墓地把1只幻想魔族怪兽特殊召唤或者自己的额外卡组（表侧）把1只幻想魔族灵摆怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end

function s.thfilter(c)
	return c:IsSetCard(0x6A19) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) then
		if rc:IsControler(tp) and rc:IsOnField() then
			local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			local b2=Duel.IsExistingMatchingCard(s.addfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
			local sel=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,2)},{b2,aux.Stringid(id,3)})
			if sel==1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
				if #g>0 then
					Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
				end
			elseif sel==2 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local g=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
				if #g>0 then
					Duel.SendtoHand(g,nil,REASON_EFFECT)
					Duel.ConfirmCards(1-tp,g)
				end
			end
		end
	end
end

function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.addfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_ILLUSION) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end

return s
