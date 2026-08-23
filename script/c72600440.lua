--食尸祭魔蝠
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_ZOMBIE),2,2)
	--①：这张卡连接召唤的场合，从卡组把1只不死族仪式怪兽送去墓地才能发动。这张卡的攻击力直到结束阶段时上升送去墓地的怪兽的原本攻击力一半数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.atkcon)
	e1:SetCost(s.atkcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--②：把墓地的这张卡除外才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的不死族怪兽解放，从手卡把1只不死族仪式怪兽仪式召唤。
	local e2=aux.AddRitualProcGreater2(c,s.filter,LOCATION_HAND,nil,s.mfilter,true)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(aux.bfgcost)
	c:RegisterEffect(e2)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.atkfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_RITUAL) and c:IsAbleToGrave()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.atkfilter,tp,LOCATION_DECK,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc and tc:IsLocation(LOCATION_GRAVE) then
		local atk=math.floor(tc:GetTextAttack()/2)
		if atk>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
function s.filter(c,e,tp,chk)
	return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_RITUAL) and (not chk or c~=e:GetHandler())
end
function s.mfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
