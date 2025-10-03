--[[
本lua的作者为藜奴儿，如果测试出bug请联系QQ：1502939196

未经允许不支持任何人的任何形式的修改，源数。如有需要请联系作者，而不是私自找人代为修改。
本人对于本lua的任何bug修改、源数和适配后来卡片均为免费，并且追诉期无限。

但是如果使用者私自修改了lua，不论是bug修复还是源数效果，本人对此lua都不会再提供任何形式的支持。
一旦发现任何其他人对本lua进行了任何形式的修改，本人首先自愿放弃此lua除必要署名权以外的所有权利，
同时再也会不承担对此lua的任何维护与后续适配，包括但不限于任何形式的bug修复、效果源数。

如果您想要修改此lua，可以先联系本人，本人会在第一时间进行回复。
并且我承诺，若本人在2天内没有回复您，上述注意事项可作废，您可以直接修改此lua，而后续debug与适配仍然由我来进行。

如果您对本lua有任何疑问，请联系本人，本人会在第一时间进行回复。
如果您对本lua有任何建议，请联系本人，本人会在第一时间进行处理。
]]

--刻界-降星
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

end
function s.filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		if mat_filter then mg=mg:Filter(mat_filter,nil,e,tp,true) end
		local exg=nil
		if grave_filter then
			exg=Duel.GetMatchingGroup(Auxiliary.RitualExtraFilter,tp,LOCATION_GRAVE,0,nil,grave_filter)
		end
		return Duel.IsExistingMatchingCard(Auxiliary.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,s.filter,e,tp,mg,exg,Card.GetLevel,"Equal",true)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	if grave_filter then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
	end
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	::RitualUltimateSelectStart::
	local mg=Duel.GetRitualMaterial(tp)
	if mat_filter then mg=mg:Filter(mat_filter,nil,e,tp) end
	local exg=nil
	if grave_filter then
		exg=Duel.GetMatchingGroup(Auxiliary.RitualExtraFilter,tp,LOCATION_GRAVE,0,nil,grave_filter)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,Auxiliary.NecroValleyFilter(Auxiliary.RitualUltimateFilter),tp,LOCATION_HAND,0,1,1,nil,s.filter,e,tp,mg,exg,Card.GetLevel,"Equal")
	local tc=tg:GetFirst()
	local mat
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if exg then
			mg:Merge(exg)
		end
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local lv=Card.GetLevel(tc)
		Auxiliary.GCheckAdditional=Auxiliary.RitualCheckAdditional(tc,lv,"Equal")
		mat=mg:SelectSubGroup(tp,Auxiliary.RitualCheck,true,1,lv,tp,tc,lv,"Equal")
		Auxiliary.GCheckAdditional=nil
		if not mat then goto RitualUltimateSelectStart end
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
		if mat:IsExists(Card.IsCode,1,nil,12950104) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(s.efilter)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
			tc:RegisterEffect(e1)
		end
	end
end

function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner() and te:IsActivated()
end
