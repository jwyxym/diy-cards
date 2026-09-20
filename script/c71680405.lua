--四方主宰 拯溺
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,1,1)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetOperation(s.reop)
	c:RegisterEffect(e1)
end
function s.matfilter(c)
	return c:IsLinkSetCard(0x597)
end
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_USE_EXTRA_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		c:RegisterEffect(e1)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.BreakEffect()
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_DECK,0,nil)
		if #g>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,nil)>0 then
			local nt={}
			for i,n in ipairs({9028399,19420830,39505816,62850093}) do
				table.insert(nt,n)
				table.insert(nt,OPCODE_ISCODE)
				if i>1 then table.insert(nt,OPCODE_OR) end
			end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
			local code=Duel.AnnounceCard(tp,table.unpack(nt))
			Duel.Hint(HINT_CARD,tp,code)
			local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_DECK,0,nil,code)
			local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
			local seq=-1
			local tc=g:GetFirst()
			while tc do
				if tc:GetSequence()>seq then
					seq=tc:GetSequence()
				end
			 tc=g:GetNext()
		 end
		  if seq==-1 then
			 Duel.ConfirmDecktop(tp,dcount)
			  Duel.ShuffleDeck(tp)
			 return
		  end
			 Duel.ConfirmDecktop(tp,dcount-seq)
				Duel.DisableShuffleCheck()
				Duel.Remove(Duel.GetDecktopGroup(tp,dcount-seq),POS_FACEDOWN,REASON_EFFECT)
			end
	end
end
